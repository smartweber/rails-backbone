class PostWorker
  include Sidekiq::Worker

  def perform(method, *args)
    Post.send("#{method}", *args)
  end

  def self.post_updated(*args)
    self.perform_async(:post_updated, *args)
  end
end
