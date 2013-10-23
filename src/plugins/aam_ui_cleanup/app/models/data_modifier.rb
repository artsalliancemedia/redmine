class DataModifier
  def run
		
		#Remove unwanted trackers created by /lib/redmine/default_data/loader.rb
		Tracker.destroy(1) if Tracker.exists?(1)
		Tracker.destroy(2) if Tracker.exists?(2)
		#Modify the support tracker to remove some of the default "Standard fields" (Admin->Trackers->Edit)
		if Tracker.exists?(3)
			t = Tracker.find(3)
			#Can't use the update method - this field is protected - so do manually.
			t.fields_bits = 204 #magic number representing the bit pattern to disable unwanted fields
			t.save
		end
		
		#Create the lifeguard project
		unique_project_identifier = "lifeguard"
		unless Project.find_by_identifier(unique_project_identifier)
			lifeguard = Project.new
			lifeguard.name = I18n.t(:lifeguard)
			lifeguard.is_public = false
			lifeguard.identifier = unique_project_identifier
			lifeguard.use_datetime_for_issues = true
			lifeguard.enabled_module_names = [:issue_tracking, :boards]
			lifeguard.save
			
			#create knowledge base categories? Names aren't important - easy to modify
			lifeguard.boards.create(name: "Software", description: "Anything software related")
			lifeguard.boards.create(name: "Hardware", description: "Anything hardware related")
			
			#TODO some more modifications as necessary
			
			puts "Project Lifeguard has been created"
		else
			puts "Project Lifeguard already exists"
		end
  end
	
end