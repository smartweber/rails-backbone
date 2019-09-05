class NewsItem < ActiveRecord::Base
  extend FriendlyId
  friendly_id :title, use: :slugged
  acts_as_list add_new_at: nil, scope: [:news_item_type]
  include Trendable
  include RepositionByPlaceSwap

  belongs_to :news_subject

  validates_uniqueness_of :url
  validate :trending_until_is_in_future, on: [:create, :update], unless: 'self.position.nil?'

  before_create :set_default_values
  after_save :reposition, if: 'self.position_changed?'

  scope :asc_by_position, ->{ order('position ASC').where('position IS NOT NULL') }
  scope :asc_by_position_and_published_at, ->{ order('-position DESC, published_at DESC') }
  scope :news_carousel, ->{ order('position ASC').where('position > 8 AND position < 18') }
  scope :ranging_by, ->(lowBorder, highBorder) { order('position ASC').where('position >= ? AND position <= ?', lowBorder, highBorder) }

  # TODO: rename that. Looks horrible
  mount_uploader :news_thumbnail, NewsThumbnailUploader

  def reposition
    raise NotImplementedError
  end

  # Downcases every first word in sentence to reduce weight of those words during keywords extraction
  def partially_downcased_summary
    self.sanitized_summary.gsub(/(?:^|(?:\.\s))(\w+)/) {|s| s.downcase }
  end

  def title=(new_title)
    obfuscated_title = Sanitize.fragment(new_title)
    self['title'] = obfuscated_title.try(:squish)
  end

  def sanitized_summary
    Sanitize.fragment(self.summary)
  end

  def news_thumbnail_stretched_full_url
    self.news_thumbnail.stretched_full.url
  end

  def news_thumbnail_carousel_list_url
    self.news_thumbnail.carousel_list.url
  end

  def self.policy_class
    NewsArticlePolicy
  end

  private

  def trending_until_is_in_future
    if self.trending_until and self.trending_until <= Time.current
      errors.add(:trending_until, 'should contain future date')
    end
  end

  def set_default_values
    raise NotImplementedError
  end
end
