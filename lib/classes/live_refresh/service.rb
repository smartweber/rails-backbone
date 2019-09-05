module LiveRefresh

  class Service
    def initialize
      @redis  = EM::Hiredis.connect(Rails.configuration.redis.main_url)
      @ns     = Rails.configuration.redis.faye.namespace
      # replace with pubsub = EM::Hiredis::PubsubClient.new(<host>, <port>).connect
      @pubsub = @redis.pubsub
      add_listeners
      add_timers
    end

    private

    def add_timers
      EM.add_periodic_timer(8) do
        refresh_companies_with_viewers
      end
      EM.add_periodic_timer(15) do
        refresh_trending_stream
      end
    end

    def add_listeners
      @pubsub.psubscribe(@ns + "/api/subscriptions/c/*")
      @pubsub.on(:pmessage) do |key, channel, message|
        publish(channel.gsub(@ns, ''), message)
      end
    end

    def refresh_trending_stream
      posts   = Tagging.recent_posts_by_tags(Company.trending_company_abbrs, 30.seconds.ago)
      if posts.size > 0
        message = RablHelper.render('api/posts/_basic_index', posts, {posts: posts})
        publish(Rails.application.routes.url_helpers.api_subscriptions_trending_stream_path, message)
      end
    end

    # @abstract In order to retrieve not outdated list of subscribers all determining if client is
    # still subscribed is outsourced to Faye network internals
    def refresh_companies_with_viewers
      abbr_arr = RedisApi.client.scan_each(match: "#{@ns}/channels/api/subscriptions/c/*",
                                           count: QuoteMedia::Service::MAX_QUOTES_PER_REQUEST).to_a
      abbr_arr.uniq.each_slice(100) do |keys|
        abbr_arr = keys.map{|key| LiveRefresh.extract_abbr_from(key)}
        QuoteMedia.client.get_quote(abbr_arr)
      end
    end

    def publish(channel, message)
      Bayeux.client.publish(channel, message)
    end
  end
end
