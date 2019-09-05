require 'open-uri'

module QuoteMedia

  def self.client
    @client ||= Service.new
  end

  class Service
    URLS = {
      quotes: "http://app.quotemedia.com/data/getQuotes.json?",
      fundamentals: "http://app.quotemedia.com/data/getFundamentalsByExchange.json?"
    }
    MAX_QUOTES_PER_REQUEST     = 100
    SORTED_QUEUE_KEY           = "quotes:sorted_refresh_queue"
    QUOTES_LISTING_KEY         = "quotes:listing"
    QUOTE_TIMESTAMP_KEY_PREFIX = "quotes:symbol_timestamp_relationship_for:"
    TIMEPOINT                  = "2016-01-01 00:00:00 UTC"
    EXCHANGE_OPENING_TIME      = "06:15"
    EXCHANGE_CLOSING_TIME      = "20:15"
    API_REQUESTS_USED_KEY      = "quotemedia:get_quote:usage"

    attr_accessor :webmaster_id, :timepoint, :exchange_timezone, :ns

    def initialize
      @webmaster_id      = APP_CONFIG[:quote_media][:webmaster_id]
      @exchange_timezone = ActiveSupport::TimeZone.new("Eastern Time (US & Canada)")
      @timepoint         = TIMEPOINT.to_time.in_time_zone(@exchange_timezone)
      @ns                = Rails.configuration.redis.faye.namespace
    end

    # getQuote QM API client method
    # @param [Array<String>] symbols
    # @return [Array<Hash>] quotes
    def get_quote(symbols)
      # TODO: add loop if symbols.size > 100
      raise "Too many symbols provided for one request. Max is #{MAX_QUOTES_PER_REQUEST}" if symbols.size > 100
      symbols          = [symbols].flatten
      relative_time    = ticks_since_timepoint
      retrieved_quotes = []

      symbols_to_request    = outdated_symbols_amongst(symbols, relative_time) + not_saved_symbols(symbols)
      locally_saved_symbols = symbols - symbols_to_request
      locally_saved_quotes, integrity_broken_symbols = get_local_quotes(locally_saved_symbols)
      symbols_to_request   += integrity_broken_symbols

      # if nothing needs to be requested - skip requesting additional things
      unless symbols_to_request.empty?
        symbols_to_request += outdated_symbols_except(symbols, relative_time) + soon_to_be_outdated_quotes(symbols, symbols_to_request, relative_time)
        retrieved_quotes    = retrieve_quotes(symbols_to_request)
        save_quotes(retrieved_quotes)
      end

      exclude_not_relevant(symbols, retrieved_quotes) + locally_saved_quotes
    end

    private

    def get_local_quotes(symbols)
      results = []
      storage_integrity_broken_symbols = []
      symbols.map do |symbol|
        begin
          sorted_list_key = RedisApi.client.get(full_key_address_for(symbol))
          result          = RedisApi.client.zrangebyscore(SORTED_QUEUE_KEY, sorted_list_key, sorted_list_key)
          # Just in case there's 2 elements with same expiration date-key
          result = if result.is_a?(Array)
            result.find{|e| JSON.parse(e)["symbolstring"] == symbol }
          end
          raise if result.nil?
          results.push(result)
        rescue
          # integrity of saved symbol-related data is broken
          storage_integrity_broken_symbols.push(symbol)
        end
      end
      [results.flatten.map!{|e| JSON.parse(e)}, storage_integrity_broken_symbols]
    end

    def full_key_address_for(symbol)
      QUOTE_TIMESTAMP_KEY_PREFIX + symbol
    end

    def ticks_since_timepoint(current_est_time: exchange_timezone.now, advance_in_seconds: 0)
      (((current_est_time + advance_in_seconds - timepoint) / 3600).round(6) * 1_000_000).to_i
    end

    def relative_time_since_closing
      last_closing_time = EXCHANGE_CLOSING_TIME.to_time.in_time_zone(exchange_timezone)
      while last_closing_time.future? or last_closing_time.saturday? or last_closing_time.sunday?
        last_closing_time = last_closing_time.advance(days: -1)
      end
      ticks_since_timepoint(current_est_time: last_closing_time)
    end

    def exchange_active_now?
      true
      # current_est_time = exchange_timezone.now
      # unless current_est_time.saturday? or current_est_time.sunday?
      #   (EXCHANGE_OPENING_TIME..EXCHANGE_CLOSING_TIME).include?(current_est_time.strftime("%H:%M"))
      # else
      #   false
      # end
    end

    def increment_quota_counter
      RedisApi.client.incr(API_REQUESTS_USED_KEY)
    end

    def not_saved_symbols(symbols)
      symbols - RedisApi.client.smembers(QUOTES_LISTING_KEY)
    end

    def prepare_query(symbols)
      symbols_param = "symbols=" + [symbols].flatten.join(',')
      URLS[:quotes] + symbols_param + webmaster_param
    end

    def retrieve_quotes(symbols)
      url    = prepare_query(symbols[0..MAX_QUOTES_PER_REQUEST-1].uniq)
      stream = fake_response_for(symbols[0..MAX_QUOTES_PER_REQUEST-1].uniq)
      # stream = open(url, 'User-Agent' => 'StockHarp/0.1')
      increment_quota_counter
      unless stream.respond_to?(:path)
        file = Tempfile.new('qmapi')
        file.binmode
        IO.copy_stream(stream, file)
      end
      begin
        file_with_response = file || stream
        parse(File.read(file_with_response)) || []
      ensure
        file_with_response.close
        file_with_response.unlink
      end
    end

    def soon_to_be_outdated_quotes(symbols, symbols_to_request, relative_time)
      capacity_left    = MAX_QUOTES_PER_REQUEST - symbols_to_request.size
      values_amount    = MAX_QUOTES_PER_REQUEST + symbols_to_request.size
      quotes           = RedisApi.client.zrangebyscore(SORTED_QUEUE_KEY, relative_time, '+inf', limit: [0, values_amount])
      proposed_symbols = symbols_from_quotes(quotes)
      (proposed_symbols - symbols_to_request)[0..capacity_left]
    end

    def get_outdated_symbols(relative_time)
      last_updated_at = if exchange_active_now?
        relative_time
      else
        relative_time_since_closing
      end
      outdated_quotes = RedisApi.client.zrangebyscore(SORTED_QUEUE_KEY, 0, last_updated_at)
      symbols_from_quotes(outdated_quotes)
    end

    # Finds symbols quotes about which should be refreshed
    def outdated_symbols_amongst(symbols, relative_time)
      symbols & get_outdated_symbols(relative_time)
    end

    # TODO: not very effective to ask for same thing(see .outdated_symbols_amongst) twice
    def outdated_symbols_except(symbols, relative_time)
      get_outdated_symbols(relative_time) - symbols
    end

    def symbols_from_quotes(json)
      json.map{|e| JSON.parse(e)["symbolstring"] }
    end

    def parse(response)
      response && response.length >= 2 ? JSON.parse(response)["results"]["quote"] : nil
      #JSON.parse(response)["results"]["quote"]
    end

    def save_quotes(quotes)
      quotes.each do |quote|
        deprecation_time     = ticks_since_timepoint(advance_in_seconds: 8)
        abbr                 = quote["symbolstring"]
        old_deprecation_time = RedisApi.client.get(full_key_address_for(abbr))
        RedisApi.client.multi do
          if old_deprecation_time
            RedisApi.client.zremrangebyscore(SORTED_QUEUE_KEY, old_deprecation_time, old_deprecation_time)
          end

          RedisApi.client.zadd(SORTED_QUEUE_KEY, deprecation_time, quote.to_json)
          RedisApi.client.sadd(QUOTES_LISTING_KEY, abbr)
          RedisApi.client.set(full_key_address_for(abbr), deprecation_time)
        end
        RedisApi.client.publish(ns + Rails.application.routes.url_helpers.api_subscriptions_company_path(abbr), quote.to_json)
      end
    end

    def exclude_not_relevant(symbols, quotes_json)
      quotes_json.keep_if{|e| symbols.include?(e["symbolstring"])}
    end

    def webmaster_param
      "&webmasterId=#{webmaster_id}"
    end

    def fake_response_for(symbols)
      StringIO.new( {results: { quote: symbols.map{|s| fake_hash_for(s)} }}.to_json )
    end

    def fake_hash_for(symbol)
      {
        "delaymin": 15,
        "equityinfo": {
            "longname": "Oracle Corp.",
            "shortname": symbol
        },
        "fundamental": {
            "eps": 2.34,
            "marketcap": 16685380000 + rand(100),
            "dividend": {
              "amount": 0.48,
                "yield": 1.315,
                "paydate": "2014-01-28",
                "frequency": "Q",
                "latestamount": {
                    "content": 0.12,
                    "currency": "USD"
                },
                "date": "2014-01-03"
            },
            "pbratio": 3.829,
            "week52low": {
                "content": 29.86,
                "date": "2013-06-26"
            },
            "week52high": {
                "content": 38.77,
                "date": "2014-01-16"
            },
            "peratio": 16.3,
            "sharesoutstanding": 4497409000,
            "sharesescrow": 0
        },
        "datatype": "equity",
        "datetime": "2014-01-28T16:22:48-05:00",
        "entitlement": "DL",
        "pricedata": {
            "vwap": 36.7921959,
            "tradevolume": 66934,
            "last": 37.1 + rand(1..10),
            "change": 0.61+rand(0.3..0.5),
            "bidsize": 100,
            "sharevolume": 13891606,
            "changepercent": 1.6717+rand(0.2..0.3),
            "asksize": 1000,
            "open": 36.6,
            "rawasksize": 10,
            "prevclose": 36.49,
            "rawbidsize": 1,
            "high": 37.13,
            "low": 36.58,
            "ask": 37.14,
            "bid": 37.1,
            "lasttradedatetime": "2014-01-28T16:17:36-05:00"
        }, "key": {
            "symbol": "ORCL",
            "exchange": "NYE"
        },
        "symbolstring": symbol
      }
    end
  end
end
