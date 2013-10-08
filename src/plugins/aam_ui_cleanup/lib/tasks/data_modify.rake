namespace :lifeguard do
  desc 'Adds initial lifeguard data to the db, and removes some Redmine defaults'
  task :data_modify => :environment do
		DataModifier.new.run
  end
end
