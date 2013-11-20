require 'net/http'
require 'net/https'
require 'json'

class ProducerAlertsToTickets
  
  def query_api
    url_base = Setting.plugin_aam_producer_alerts['producer_alerts_url']
    auth = {
      username: Setting.plugin_aam_producer_alerts['username'],
      password: Setting.plugin_aam_producer_alerts['password']
    }
    params = '?username=' + auth[:username] + '&password=' + auth[:password] + '&q={"type":"ticket"}'
    uri = URI.join( url_base, URI.encode(params) )
    http = Net::HTTP.new(uri.host, uri.port)
    
    if url_base.include? "https"
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end
    
    req = Net::HTTP::Get.new(uri.request_uri)
    return http.request(req)
  end
  
  def add_tickets_from_alerts
    response_json = (ActiveSupport::JSON.decode query_api.body)["data"]
    @alerts_count = response_json['count']
    puts "Producer returned #{@alerts_count} alerts" if @debugging
    
    response_json['alerts'].each do |alert|
      #Skip un-ticketable alerts
      if alert['ticket_uuid']
        is_active = alert['active']
        is_new = Issue.find_by_uuid alert['ticket_uuid']
        
        if is_active and not is_new
          puts "Ticketising new alert: " + alert['subject'] if @debugging

          ticket = Issue.new
          #Guaranteed fields from Producer
          ticket.uuid = alert['ticket_uuid']
          ticket.subject = alert['subject']
          ticket.description = alert['description']

          complex = Cinema.find_by_external_id alert['complex_id']
          ticket.cinema_id = complex.id if complex

          screen = Screen.find_by_uuid alert['screen_uuid']
          ticket.screen_id = screen.id if screen

          device = Device.find_by_uuid alert['device_uuid']
          ticket.device_id = device.id if device

          #Open the ticket immediately
          ticket.start_date = DateTime.now

          #Add required fields to pass the active record callbacks for an Issue
          anonymous_user = User.first
          ticket.author_id = anonymous_user.id #Anonymous
          ticket.project_id = Project.first.id #Hopefully Lifeguard
          ticket.tracker_id = Tracker.first.id #Hopefully Support

          # TODO: Work around custom fields with required attributes.
          # ticket.required_attribute_names(anonymous_user).each do |attr|
          # end

          #Print error messages in debug mode
          success = @debugging ? ticket.save! : ticket.save

          @new_count += 1 if success
        elsif not is_active and is_new
          puts "Closing ticket for inactive alert: " + alert['subject'] if @debugging
          producer_closed_status = IssueStatus.find_by_name_raw 'closed'
          if producer_closed_status
            is_new.status = producer_closed_status
            is_new.save
            @closed_count += 1
          else
            redmine_closed_status = IssueStatus.find_by_is_closed true
            if redmine_closed_status
              is_new.status = redmine_closed_status
              is_new.save
              @closed_count += 1
              puts "Closing ticket using first Redmine 'closed' status (no Producer 'closed' status found)"
            else
              puts "Could not close ticket - no 'closed' issue status available"
            end
          end
        else
          @skipped_count += 1
        end
      else
        @skipped_count += 1
      end
    end
  end
    
  def run(debug)
    @debugging = debug || true
    puts "Start, #{Time.now.to_s}:  Running Producer alerts_to_tickets with debugging " + @debugging.to_s

    @new_count = 0
    @alerts_count = 0
    @skipped_count = 0
    @closed_count = 0
    
    add_tickets_from_alerts
    
    error_count = @alerts_count - @new_count - @skipped_count - @closed_count
    puts "WARNING! #{error_count} new alerts could not be ticketised. Run task in debug mode to solve." if error_count > 0
    
    puts "End, #{Time.now.to_s}:  #{@new_count} alerts were ticketised, #{@closed_count} were closed (#{@skipped_count} skipped)."
  end
  
end