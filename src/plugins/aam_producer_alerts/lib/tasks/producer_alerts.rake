namespace :lifeguard do
  desc 'Creates tickets from Producer alerts'
  task :producer_alerts, [:debugging] => :environment do |task, args|
		ProducerAlertsToTickets.new.run (args.debugging)
  end
end
