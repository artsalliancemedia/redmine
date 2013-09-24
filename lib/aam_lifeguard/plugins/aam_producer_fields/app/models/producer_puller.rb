require 'net/http'
require 'net/https'

class ProducerPuller
  
  def query_api(path)
		path += '?username=' + Setting.plugin_aam_producer_fields['username'] +
			'&password=' + Setting.plugin_aam_producer_fields['password']
		
		url_base = Setting.plugin_aam_producer_fields['producer_url'];		
		uri = URI.join(url_base, path)
		http = Net::HTTP.new(uri.host, uri.port)
		
		if url_base.include? "https"
			http.use_ssl = true
			http.verify_mode = OpenSSL::SSL::VERIFY_NONE
		end
		
		req = Net::HTTP::Get.new(uri.request_uri)
		return http.request(req)
  end

  def insert_complexes
    response = query_api('complexes')
    complexes_obj = ActiveSupport::JSON.decode(response.body)["data"]["complexes"]
		
    @complexes_saved = 0
    @complexes_skipped = 0

    complexes_obj.each do |complex_obj|
      existing = Cinema.find_by_external_id(complex_obj["id"])

      if(!existing)
        cinema = Cinema.new
        cinema.name = complex_obj["name"]
        cinema.telephone = complex_obj["telephone"]
        cinema.ip_address = complex_obj["ip_address"]
        cinema.external_id = complex_obj["id"]
        cinema.save
        @complexes_saved += 1
      else
        @complexes_skipped += 1
      end
    end
		puts @complexes_saved.to_s + " complexes saved"
		puts @complexes_skipped.to_s + " complexes skipped"
  end
  
  def insert_screens
    response = query_api('screens')
    screens_obj = ActiveSupport::JSON.decode(response.body)["data"]["screens"]

    @screens_saved = 0
    @screens_skipped = 0

    screens_obj.each do |screen_obj|
      existing = Screen.find_by_uuid(screen_obj["uuid"])
      if(!existing)
        screen = Screen.new
        screen.title = screen_obj["title"]
        screen.uuid = screen_obj["uuid"]
        screen.identifier = screen_obj["identifier"]

        if(Cinema.find_by_external_id(screen_obj["complex_id"]))
          screen.cinema_id = Cinema.find_by_external_id(screen_obj["complex_id"]).id
          screen.save
          @screens_saved += 1
        else
          @screens_skipped += 1
        end
      else
        @screens_skipped += 1
      end
    end
		puts @screens_saved.to_s + " screens saved"
		puts @screens_skipped.to_s + " screens skipped"
  end

  def insert_devices
    response = query_api('devices')
    devices_obj = ActiveSupport::JSON.decode(response.body)["data"]["devices"]

    @devices_saved = 0
    @devices_skipped = 0

    devices_obj.each do |device_obj|
      existing = Device.find_by_uuid(device_obj["uuid"])

      if(!existing)
        device = Device.new
        device.category = device_obj["category"]
        device.ip_address = device_obj["ip_address"]
        device.identifier = device_obj["uuid"]
        device.uuid = device_obj["uuid"]

        if(device_obj["screen_uuid"] && Screen.find_by_uuid(device_obj["screen_uuid"]))
          device.deviceable_id = Screen.find_by_uuid(device_obj["screen_uuid"]).id
          device.deviceable_type = "Screen"
        elsif(Cinema.find_by_external_id(device_obj["complex_id"]))
          device.deviceable_id = Cinema.find_by_external_id(device_obj["complex_id"]).id
          device.deviceable_type = "Cinema"
        else
          @devices_skipped += 1
          next
        end

        if(device_obj["monitoring_info"])
          monitoring_info = ActiveSupport::JSON.decode(device_obj["monitoring_info"].gsub("\\\"", "\""))
          if(monitoring_info["software_version"])
            device.software_version = monitoring_info["software_version"]
          end
          if(monitoring_info["model"])
            device.model = monitoring_info["model"]
          end
          if(monitoring_info["firmware_version"])
            device.firmware_version = monitoring_info["firmware_version"]
          end
        end

        device.save
        @devices_saved += 1
      else
        @devices_skipped += 1
      end
    end
		puts @devices_saved.to_s + " devices saved"
		puts @devices_skipped.to_s + " devices skipped"
  end
  
	def pull
		insert_complexes
		insert_screens
		insert_devices    
  end
  
end