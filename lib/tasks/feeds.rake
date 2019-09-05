namespace :feeds do
  desc "Fetch and save feeds"
  task :fetch => :environment do
    scraper = FeedScraper.new
    results = scraper.run
    puts results
  end

  task :clean => :environment do
    desc "Destroys old feeds"
    NewsItem.where('created_at < ?', Time.current.advance(days: -7)).find_each(batch_size: 100) do |ni|
      ni.destroy
    end
  end
end
