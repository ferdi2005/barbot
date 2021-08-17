task :update_feed => :environment do
    puts 'Updating feed...'
    UpdateRssJob.perform_now
end