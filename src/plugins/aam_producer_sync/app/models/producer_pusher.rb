require 'net/http'
require 'net/https'
require 'json'
require 'pp'

class ProducerPusher
	
  def api_request(body, url_extension)

		url_base = Setting.plugin_aam_producer_sync['producer_sync_url'] + url_extension
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
		req.body = body.to_json
		req.content_type = 'application/json'

		return http.request(req)
  end
	
	def send_tickets(last_sent_time, curr_time)
		#If an issue is closed, updated_on will change,
		#	what we need to watch is open issues edging silently into breach by passing their due date (or near-breach date).
		#	Rarely (working periods change or issue_priority->sla_seconds change),
		#	 the due dates of multiple tickets will change dramatically so we will want to re-sync all open tickets for safety
		dramatic_sla_change_path = Rails.root.join('plugins', 'aam_sla', 'assets', "changetime.stor").to_s
		dramatic_sla_change = File.exist?(dramatic_sla_change_path) && File.read(dramatic_sla_change_path) >= last_sent_time 
		issues = (dramatic_sla_change) ?
			Issue.where("updated_on > ? OR closed_on IS NULL", last_sent_time) :
			Issue.where("updated_on > ? OR (closed_on IS NULL AND (due_date BETWEEN ? AND ? OR near_breach_date BETWEEN ? AND ? OR uuid IS NULL))",
				last_sent_time, last_sent_time, curr_time, last_sent_time, curr_time)
		
		@@ticket_count = issues.length
		return true if @@ticket_count == 0
		
		puts "Attempting to sync #{@@ticket_count} tickets"
			
		issues.each do |issue|
			ticket_id = issue.id.to_s
			puts "Processing ticket #" + ticket_id if @@debugging
						
			issue_slimmed = { #compulsory or derived fields
				subject: issue.subject,
				complex_id: issue.cinema.external_id,
				status: issue.status.name_raw,
				priority: issue.priority.position,
				sla_status: issue.sla_status_raw,
				url: Setting["protocol"] + "://" + Setting["host_name"] + "/issues/" + ticket_id, #derived
				opened_on: issue.created_on.to_i
			}
			issue_slimmed["closed_on"] = issue.closed_on.to_i if issue.closed_on
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

			response = api_request( issue_slimmed, '' )
			status = response.code

			ticket_id_info = "#{ticket_type} ticket ##{ticket_id}"

			if (status != '200')
				#Server or auth error, don't bother continuing
				puts status + " Error. Terminating task now."
				puts response.body if @@debugging
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
			else
				#If a ticket can't be sent, it is usually because Producer doesn't have a record of the
				#screen, device or cinema of the ticket. Because we pull this data from Producer, this should
				#only happen when Producer deletes some of this data (whereas we keep legacy screens/devices/cinemas)
				#Therefore, it is safe to ignore tickets which couldn't be sent, and not bother trying to re-send them.
				puts "#{ticket_id_info} not sent due to Producer error."
				error = response["messages"][0]["msg"] || "Unknown"
				puts error if @@debugging
			end
			puts "" if @@debugging
		end
		return true
	end
	
	def delete_deleted_tickets
		#Get list of uuids of deleted issues
		deleted_issues = DeletedIssue.select(:uuid).map { |di| di.uuid }
		deleted_issues_obj = { uuids: deleted_issues }
		
		@@deletable_count = deleted_issues.length
		return true if @@deletable_count == 0
		
		response = api_request( deleted_issues_obj, '/multi_delete' )
		puts response.body if @@debugging
		status = response.code
		
		if (status != '200')
			puts status + " Error. Terminating task now."
			return false
		end
		
		#Find ids of successfully deleted tickets
		response_obj = JSON.parse response.body
		succesful_deletees = response_obj['data']
		if succesful_deletees && succesful_deletees.length > 0
			DeletedIssue.where(:uuid => succesful_deletees).destroy_all
			@@deleted_count = succesful_deletees.length
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
		succesful = send_tickets( last_run_time, this_run_time )
		
		@@deleted_count = 0
		succesful = delete_deleted_tickets if succesful

		if succesful
			file = open(last_run_path, 'w')
			file.write this_run_time
			file.close
			
			if @@ticket_count + @@deletable_count > 0
				puts "#{Time.now.to_s}  #{@@success_count} out of #{@@ticket_count} tickets were synced. #{@@deleted_count} of #{@@deletable_count} successfully deleted"
			else
				puts "#{Time.now} Nothing to sync or delete"
			end
		end
	end
  
end