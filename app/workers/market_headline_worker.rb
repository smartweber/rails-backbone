# REFACTOR
class MarketHeadlineWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker

  def expiration
    @expiration ||= 60*60*7 # store job details for 7 hours max
  end

  def perform(method, *args)
    self.class.send("#{method}", *args)
  end

  def self.remove_from_trending(id)
    market_headline = MarketHeadline.find(id)
    market_headline.remove_from_list
  end
end
