require 'net/http'
require 'net/https'
require 'json'
require 'pp'

class ProducerPusher
	
  def query_api(ticket_slimmed)

		url_base = Setting.plugin_aam_producer_sync['producer_sync_url'];		
		auth = {
			username: Setting.plugin_aam_producer_sync['username'],
			password: Setting.plugin_aam_producer_sync['password']
		}
		params = '?username=' + auth[:username] + '&password=' + auth[:password]
		uri = URI.join(url_base, params)
		http = Net::HTTP.new(uri.host, uri.port)
			
		if uri.to_s.include? "https"
			http.use_ssl = true
			http.verify_mode = OpenSSL::SSL::VERIFY_NONE
		end
		
		req = Net::HTTP::Post.new(uri.request_uri)
		req.body = ticket_slimmed.to_json
		req.content_type = 'application/json'

		return http.request(req)
  end
	
	def send_tickets(last_sent_time)
		issues = Issue.where("updated_on > ?", last_sent_time)
		@@ticket_count = issues.length.to_s
		puts "Attempting to sync " + @@ticket_count + " tickets"

		issues.each do |issue|
			ticket_id = issue.id.to_s
			issue_slimmed = { #compulsory or derived fields
				subject: issue.subject,
				complex_id: issue.cinema.external_id,
				status: issue.status.name_raw,
				sla_status: issue.sla_status_raw,
				url: Setting["protocol"] + "://" + Setting["host_name"] + "/issues/" + ticket_id #derived
			}
			#Add optional fields, if present
			if issue.screen
				issue_slimmed["screen_uuid"] = issue.screen.uuid
			end
			if issue.device
				issue_slimmed["device_uuid"] = issue.device.uuid
			end

			if issue.uuid #updating previously-sent ticket
				issue_slimmed["uuid"] = issue.uuid
				ticket_type = "Updated"
			else
				ticket_type = "New"
			end

			response = query_api(issue_slimmed)
			status = response.code

			ticket_id_info = "#{ticket_type} ticket ##{ticket_id}"

			if (status != '200')
				puts status + " Error. Terminating task now."
				return false
			end

			response = JSON.parse response.body
			uuid = response["data"]["uuid"]
			if uuid
				puts "#{ticket_id_info} sent successfully"
				@@success_count += 1
				#Execute raw SQL to overcome redmine complaints about irrelevant fields (e.g. due date), and
				#prevent auto updating of the updated_on timestamp field,
				# which preferably should not change when the uuid is added.
				execute_sql = ActiveRecord::Base.connection.execute("
					UPDATE issues 
					SET uuid=#{ActiveRecord::Base.sanitize(uuid)}
					WHERE id=#{ticket_id}
				")
				puts execute_sql if @@debugging
				#Don't do this now, do above raw SQL execution instead
#				issue.uuid = uuid
#				was_success = issue.save
#
#				if was_success
#					puts "#{ticket_id_info} sent successfully"
#				else
#					puts "#{ticket_id_info} sending failed due to Redmine error."
#					pp issue.errors if @@debugging
#				end
			else
				puts "#{ticket_id_info} not sent due to Producer error."
				error = response["messages"][0]["msg"] || "Unknown"
				puts error if @@debugging
			end
			puts "" if @@debugging
		end
		return true
	end
  
	def push(debug)
		@@debugging = debug || false
		puts "Running Producer ticket sync with debugging " + @@debugging.to_s

		#Get now so we don't miss (next time) any tickets modified/created during this sync
		this_run_time = (Time.now + 1).to_s #Round up to prevent same ticket being sent again next time task runs
		
		last_run_path = Rails.root.join('plugins', 'aam_producer_sync', 'assets', "lastrun.stor").to_s 

		#default to several decades ago if not run before
		last_run_time = File.exist?(last_run_path) ? File.read(last_run_path) : Time.now - 9999999999

		puts "Looking for tickets added/modified between #{last_run_time} and #{this_run_time}"
		
		@@success_count = 0
		succesful = send_tickets last_run_time

		if succesful
			file = open(last_run_path, 'w')
			file.write this_run_time
			file.close
		end
		puts "Task completed at " + Time.now.to_s
		puts "#{@@success_count} out of #{@@ticket_count} tickets were synced"
	end
  
end