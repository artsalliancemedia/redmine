namespace :lifeguard do
  desc 'Pushes ticket data to Producer'
  task :producer_push, [:debugging] => :environment do |task, args|
		ProducerPusher.new.push (args.debugging)
  end
end
