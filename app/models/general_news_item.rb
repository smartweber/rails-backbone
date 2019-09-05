class GeneralNewsItem < NewsItem
  ITEM_TYPE = 0
  MAX_KEYWORDS = 7
  SUMMARY_PURIFIERS = { 'washington_post' => /Read full article &gt;&gt;/i,
                      'rt' => /Read Full Article at RT.com/i,
                      'cnn' => /Read full story for latest details./i,
                      'reuters' => /\(Reuters\)/i,
                      'ap' => /\(AP\)/i }

  default_scope { where(news_item_type: ITEM_TYPE) }

  has_many :attachments, as: :attachable, dependent: :destroy

  validates_presence_of :title
  validates_presence_of :agency, :url, :published_at, unless: 'locally_hosted'
  validates_presence_of :news_thumbnail, if: 'locally_hosted'
  validates :summary, presence: true, length: { minimum: 10 }

  before_save :sanitize_body

  scope :premoderated_market_headlines, ->{ order('position ASC').where('position > 0 AND position < 9') }
  scope :unique_news, ->{ (where(news_subject_id: nil).where('position IS NULL or position > 17') +
    where('position IS NULL or position > 17').where.not(news_subject_id: nil, position: nil).group(:news_subject_id)).sort_by(&:published_at) }

  mount_uploader :news_thumbnail, GeneralNewsUploader

  serialize :stemmed_keywords, Array
  serialize :not_stemmed_keywords, Array

  attr_accessor :thumbnail_x, :thumbnail_y, :thumbnail_w, :thumbnail_h

  def to_param
    self.slug
  end

  # TODO: Wrap in transaction
  def reposition
    if position
      unless trending_until_changed?
        trending_until = Time.current.advance(hours: (position_was.nil? ? 6 : 3))
        update_columns(trending_until: trending_until, updated_at: Time.current)
      end
      schedule_removal_from_trending
      if not locally_hosted and position.between?(1, 18) and news_thumbnail.url.nil?
        query        = not_stemmed_keywords.join(' ')
        first_result = GoogleApi.client.find_first_by(query)
        if first_result
          self.remote_news_thumbnail_url = first_result.link
          save
          # TODO: replace above with following once we've file storage set
          # GeneralNewsItemWorker.perform_async('fetch_google_image', self.id)
        end
      end
    else
      update_columns(trending_until: nil, updated_at: Time.current)
    end
  end

  def set_keywords!
    total_keywords            = summary_keywords.merge!(title_keywords).rank
    words_that_count          = total_keywords.map { |e| e.text }.first(MAX_KEYWORDS)
    self.not_stemmed_keywords = words_that_count
    self.stemmed_keywords     = words_that_count.map{ |w| w.stem }
  end

  def title_keywords
    GeneralNewsItem.keywords_from_content(self.title)
  end

  def summary_keywords
    GeneralNewsItem.keywords_from_content(self.partially_downcased_summary) do
      set :upper_case, 10
    end
  end

  def self.with_positions_between(low_border, high_border)
    positioned_news = ranging_by(low_border, high_border)
    positioned_news + prepare_additional_news(positioned_news, low_border, high_border)
  end

  # @note method heavily relies on fact that positioned_news contains all news positioned
  #  between low_border..high_border
  def self.prepare_additional_news(positioned_news, low_border, high_border)
    news_required = ((high_border - low_border) - positioned_news.length) + 1
    return [] if news_required == 0
    news = get_additional_news(news_required)
    occupied_positions = positioned_news.map(&:position)
    free_positions = (low_border..high_border).to_a - occupied_positions
    news.each_with_index do |news_item, i|
      news_item.trending_until = Time.new.tomorrow.at_beginning_of_day
      news_item.insert_at(free_positions[i])
    end
    news
  end

  def self.get_additional_news(news_required)
    results = {}
    i = 0
    enough_news_found = lambda{ |news_required, i| i == news_required }
    ids = GeneralNewsItem.order('created_at DESC').where(position: nil).pluck(:id)
    ids.each_slice(10) do |chunk|
      GeneralNewsItem.find(chunk).each do |gni|
        if results[gni.agency].nil? or results[gni.agency].length < 3
          results[gni.agency] ||= []
          results[gni.agency].push(gni)
          i += 1
          break if enough_news_found.call(news_required, i)
        end
      end
      break if enough_news_found.call(news_required, i)
    end
    results.values.flatten
  end

  def self.keywords_from_content(string, &config_block)
    content = Highscore::Content.new string
    content.configure &config_block if config_block
    content.keywords
  end

  def self.market_headlines
    premoderated = self.premoderated_market_headlines
    if premoderated.count == 8
      premoderated
    else
      required_amount = 8 - premoderated.count
      non_premoderated = self.unique_news.reverse.first(required_amount)
      premoderated + non_premoderated
    end
  end

  private

    def set_default_values
      self.news_item_type = ITEM_TYPE
    end

    def sanitize_body
      obfuscated_summary = if locally_hosted
        Sanitize.fragment(summary, Sanitize::Config.merge(Sanitize::Config::RELAXED,
                                        transformers: SanitizationTransformers.youtube_transformer
                                      ))
      else
        Sanitize.fragment(summary)
      end
      if SUMMARY_PURIFIERS[agency]
        obfuscated_summary = obfuscated_summary.gsub(SUMMARY_PURIFIERS[agency], '')
      end
      self.summary = obfuscated_summary.try(:squish)
    end
end
