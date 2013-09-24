require_dependency 'message'

module KbMessagePatch
  def self.included(base) # :nodoc:
    base.extend(ClassMethods)

    base.send(:include, InstanceMethods)

    base.class_eval do
      unloadable
			#need to specify join table due to inverse lexical ordering of class names, see
			#http://guides.rubyonrails.org/association_basics.html#creating-join-tables-for-has-and-belongs-to-many-associations
			has_and_belongs_to_many :issues, :join_table => "#{table_name_prefix}messages_issues#{table_name_suffix}"
    end

  end
  
  module ClassMethods
		def get_models(manufacturer)
			return Device.where("model IS NOT NULL AND manufacturer = ?", manufacturer)
				.select("DISTINCT(model)").reorder("model")
				.map { |d| d.model }
		end
		
		def get_softwares(model)
			return Device.where("software_version IS NOT NULL AND model = ?", model)
				.select("DISTINCT(software_version)").reorder("software_version")
				.map { |d| d.software_version }
		end
		def get_firmwares(model)
			return Device.where("firmware_version IS NOT NULL AND model = ?", model)
				.select("DISTINCT(firmware_version)").reorder("firmware_version")
				.map { |d| d.firmware_version }
		end
		
		
  end
  
  module InstanceMethods
  end
	
end