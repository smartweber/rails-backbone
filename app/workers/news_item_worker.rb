# REFACTOR
class NewsItemWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker

  def expiration
    @expiration ||= 60*60*7 # store job details for 7 hours max
  end

  def perform(method, *args)
    self.class.send("#{method}", *args)
  end

  def self.remove_from_trending(id)
    feed = find_by_id(id)
    feed.remove_from_list
  end

  def self.fetch_google_image(feed_id)
    feed = find_by_id(feed_id)
    search = Google::Search::Image.new(query: feed.not_stemmed_keywords.join(' '),
                                       image_size: [:medium, :large, :xlarge, :xxlarge],
                                       safety_level: :active)
    feed.remote_news_thumbnail_url = search.first.uri
    feed.save
  end

  def self.find_by_id(id)
    rescue NotImplementedError
  end
end
