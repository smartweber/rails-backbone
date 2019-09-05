# REFACTOR
class ArticleWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker

  def expiration
    @expiration ||= 60*60*7 # store job details for 7 hours max
  end

  def perform(method, *args)
    ArticleWorker.send("#{method}", *args)
  end

  def self.remove_from_trending(article_id)
    article = Article.find(article_id)
    article.remove_from_list
  end
end
