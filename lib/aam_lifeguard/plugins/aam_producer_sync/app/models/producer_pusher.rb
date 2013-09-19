require 'net/http'
require 'net/https'
require 'json'

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
		puts "Making request"
	#	puts req.body
		return http.request(req)
  end
	
	def send_tickets(last_sent_time)
		issues = Issue.where("updated_on > ?", last_sent_time)
		puts "Synching " + issues.length.to_s + " tickets to Producer"
		
		issues.each do |issue|
			ticket_id = issue.id.to_s
			issue_slimmed = {
				complex_id: issue.cinema.external_id,
				screen_uuid: issue.screen.uuid,
				device_uuid: issue.device.uuid,
				status: issue.status.name_raw,
				sla_status: issue.sla_status_raw,
				url: Setting["protocol"] + "://" + Setting["host_name"] + "/issues/" + ticket_id
			}
			if issue.uuid #updating previously-sent ticket
				issue_slimmed["uuid"] = issue.uuid
			end
			puts issue_slimmed

			response = query_api(issue_slimmed)
			status = response.code
		#	puts "Receiving response"
			if (status != '200')
				puts status + " Error. Terminating task now."
				return false
			end
			response = JSON.parse response.body
			uuid = response["data"]["uuid"]
			if uuid
				issue.uuid = response["data"]["uuid"]
				issue.save
				puts "Ticket #{ticket_id} sent succesfully"
			else
				puts "Ticket #{ticket_id} not sent. Error: "
				error = response["messages"][0]["msg"] || "Unknown"
				puts error
			end
		end
		return true
  end
  
	def push
		last_run_path = "./plugins/aam_producer_sync/assets/lastrun.stor"
		#default to several decades ago if not run before
		last_run_time = File.exist?(last_run_path) ? File.read(last_run_path) : Time.now - 9999999999
		
		succesful = send_tickets last_run_time
		ran_at = Time.now.to_s
		
		if succesful
			file = open(last_run_path, 'w')
			file.write ran_at
			file.close
		end
		puts "Finished at " + ran_at 
  end
  
end