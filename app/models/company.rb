require 'feedjira'

class Company < ActiveRecord::Base
  acts_as_list add_new_at: nil
  searchkick text_start: [:abbr], word: [:abbr], word_start: [:name]
  include Trendable
  include RepositionByPlaceSwap

  DEFAULT_ORDER = {'AAPL' => 1, 'TSLA' => 2, 'GOOGL' => 3, 'FB' => 4, 'JNJ' => 5}
  TOP_POSITIONS = 1..5
  COMPOSITE_INDEXES_ABBREVIATIONS = %W(QQQ SPY DIA)

  has_many :passive_relationships, class_name: "Relationship", dependent: :destroy, as: :followable
  has_many :followers, through: :passive_relationships, source: :follower
  has_many :news_items, class_name: 'CompanyNewsItem'

  validates_presence_of :name, :abbr, :exchange, :market_cap
  validates_uniqueness_of :abbr
  validates :position, inclusion: { in: TOP_POSITIONS, message: 'must be from 1 to 5' },
                       if: "position_changed? && position.present?"

  with_options if: 'self.position_changed?' do |context|
    context.before_save :set_default_trending_until
    context.after_save :reposition
  end
  after_save :schedule_removal_from_trending, if: :common_trading_company?

  scope :asc_by_position, ->{ order('-position DESC, name ASC') }
  scope :market_snapshot, ->{ where('abbr IN (?)', COMPOSITE_INDEXES_ABBREVIATIONS) }
  scope :by_abbr_desc,    ->{ order('abbr DESC') }
  scope :top_five,        ->{ where(position: TOP_POSITIONS) }

  attr_accessor :similarity_score

  def search_data
    {
      abbr: abbr.downcase,
      name: name,
      market_cap: market_cap
    }
  end

  def default_company?
    DEFAULT_ORDER.key?(self.abbr)
  end

  def common_trading_company?
    self.trending_until_changed? and not self.default_company? and not self.position.nil?
  end

  def set_default_trending_until
    self.trending_until = if self.default_company?
      Time.current.advance(years: 10)
    elsif self.trending_until.nil? or self.trending_until < Time.current
      Time.current.advance(hours: (self.position_was.nil? ? 6 : 3))
    else
      self.trending_until
    end
  end

  def reposition
    if self.position
      insert_at self.position
    else
      update_columns(trending_until: nil, updated_at: Time.current)
      if TOP_POSITIONS.include?(self.position_was)
        self.replace_with_default
      end
    end
  end

  # @note this method doesn't check if position lies in desired range
  #   calling this without outer check can result in errors
  def replace_with_default
    company = Company.find_by_abbr(DEFAULT_ORDER.select{ |k,v| v == current_or_previous_position }.keys.first)
    if company
      Company.transaction do
        company.set_default_trending_until
        company.update_columns(position: current_or_previous_position, updated_at: Time.current)
        self.update_columns(position: nil, updated_at: Time.current)
      end
    else
      raise "Define first five companies that would occupy the top!"
    end
  end

  def latest_news(page=1)
    if last_fetched_news_at.nil? or last_fetched_news_at < 1.hour.ago
      fetch_latest_news
    end
    news_items.order('published_at DESC').page(page).per(5)
  end

  # Todo: move to association
  def posts(page = 1)
    Post.with_cashtag(self.abbr, page)
  end

  def posts_count
    Post.all_with_cashtag(self.abbr).total_count
  end

  def followers_count
    followers.count
  end

  def quote
    quote = QuoteMedia.client.get_quote(self.abbr)
    quote.first ? quote : [empty_quote]
  end

  def empty_quote
    {
      "delaymin": 15,
      "equityinfo": {
          "longname": name,
          "shortname": abbr
      },
      "fundamental": {
          "eps": "n/a",
          "marketcap": "n/a",
          "dividend": {
            "amount": "n/a",
              "yield": "n/a",
              "paydate": "n/a",
              "frequency": "n/a",
              "latestamount": {
                  "content": "n/a",
                  "currency": "n/a"
              },
              "date": "n/a"
          },
          "pbratio": "n/a",
          "week52low": {
              "content": "n/a",
              "date": "n/a"
          },
          "week52high": {
              "content": "n/a",
              "date": "n/a"
          },
          "peratio": "n/a",
          "sharesoutstanding": "n/a",
          "sharesescrow": "n/a"
      },
      "datatype": "n/a",
      "datetime": nil,
      "entitlement": "n/a",
      "pricedata": {
          "vwap": "n/a",
          "tradevolume": "n/a",
          "last": "n/a",
          "change": "n/a",
          "bidsize": "n/a",
          "sharevolume": "n/a",
          "changepercent": "n/a",
          "asksize": "n/a",
          "open": "n/a",
          "rawasksize": "n/a",
          "prevclose": "n/a",
          "rawbidsize": "n/a",
          "high": "n/a",
          "low": "n/a",
          "ask": "n/a",
          "bid": "n/a",
          "lasttradedatetime": nil
      }, "key": {
          "symbol": abbr,
          "exchange": exchange
      },
      "symbolstring": abbr
    }
  end

  def last_fetched_news_at
    begin
      RedisApi.client.get("company:#{self.abbr.downcase}:last_fetched_news_at")
    rescue Redis::BaseConnectionError
      last_news_item_published_at
    end
  end

  def last_fetched_news_at=(datetime)
    begin
      RedisApi.client.set("company:#{self.abbr.downcase}:last_fetched_news_at", datetime)
    rescue Redis::BaseConnectionError
      nil
    end
  end

  def yahoo_news_feed_url(abbr)
    APP_CONFIG[:yahoo_finance] + abbr
  end

  def self.autocomplete_by_abbr(abbr)
    search(abbr.downcase,
           fields: [
              {"abbr^2" => :text_start},
              {"abbr^3" => :exact},
              {name: :word_start}
              ],
            limit: 5,
            boost_by: { market_cap: { factor: 1.2 } },
            misspellings: false
          )
  end

  def self.trending_company_abbrs
    select(:abbr).top_five.map(&:abbr)
  end

  private
  # @note due to logic certain methods would need current or previous value of position
  def current_or_previous_position
    self.position || self.position_was
  end

  def last_news_item_published_at
    self.news_items.last.try(:published_at) || 1.month.ago
  end

  def fetch_latest_news
    feed = Feedjira::Feed.fetch_and_parse( yahoo_news_feed_url(self.abbr) )
    # feed == 0 when there's no connection with target feed could be made
    unless feed == 0 or feed.entries.first.title.match(/RSS feed not found/)
      last_timestamp            = last_news_item_published_at
      self.last_fetched_news_at = Time.current
      amount_required           = 10 - self.news_items.count
      feed.entries.first(10).each do |item|
        if last_fetched_news_at.nil? or item.published > last_timestamp or amount_required > 0
          new_item = CompanyNewsItem.create_from_feed_item_and_company(item, self)
          amount_required -= 1 if amount_required > 0 and new_item.persisted?
        end
      end
    else
      []
    end
  rescue Faraday::ConnectionFailed
    []
  end
end
