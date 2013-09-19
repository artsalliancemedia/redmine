namespace :lifeguard do
  desc 'Pulls data from Producer'
  task :producer_pull => :environment do
    puts "Working..."
		prod_pull = ProducerPuller.new
    prod_pull.pull
  end
end
