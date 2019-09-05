module RedisApi
  def self.client
    @client ||= begin
      Redis.new(url: Rails.configuration.redis.main_url)
    end
  end
end
