namespace :lifeguard do
  desc 'Pulls data from Producer'
  task :producer_pull, [:debugging] => :environment do |task, args|
	ProducerPuller.new.pull (args.debugging)
  end
end
