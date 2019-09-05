# REFACTOR
class BreakingNewsWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker
  sidekiq_options retry: false

  def expiration
    @expiration ||= 60*60*7 # store job details for 7 hours max
  end

  def perform(method, *args)
    BreakingNewsWorker.send("#{method}", *args)
  end

  def self.remove_from_trending(id)
    breaking_news = BreakingNews.find(id)
    breaking_news.update_attribute(:trending_until, nil)
  end
end
