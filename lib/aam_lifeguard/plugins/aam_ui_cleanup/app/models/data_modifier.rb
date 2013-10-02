class DataModifier
  def run
		#Remove unwanted trackers created by /lib/redmine/default_data/loader.rb
		Tracker.destroy(1) if Tracker.exists?(1)
		Tracker.destroy(2) if Tracker.exists?(2)
		
		#Create the lifeguard project
		unless Project.find_by_identifier("lifeguard")
			lifeguard = Project.new
			lifeguard.name = I18n.t(:lifeguard)
			lifeguard.identifier = "lifeguard"
			lifeguard.use_datetime_for_issues = true
			lifeguard.enabled_module_names = [:issue_tracking, :boards]
			lifeguard.save
			
			#create knowledge base categories? Names aren't important - easy to modify
			lifeguard.boards.create(name: "Software", description: "Anything software related")
			lifeguard.boards.create(name: "Hardware", description: "Anything hardware related")
			
			#Do some more inserts as necessary
			puts "Project Lifeguard has been created"
		else
			puts "Project Lifeguard already exists"
		end
  end
	
end