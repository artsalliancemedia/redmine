namespace :lifeguard do
  desc 'Pushes ticket data to Producer'
  task :producer_push => :environment do
    puts "Working..."
		prod_push = ProducerPusher.new
    prod_push.push
  end
end
