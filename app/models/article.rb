class Article < ActiveRecord::Base
  acts_as_list add_new_at: nil
  include Trendable
  include RepositionByPlaceSwap
  extend FriendlyId
  friendly_id :title, use: :slugged

  has_many :attachments, as: :attachable, dependent: :destroy
  has_many :posts, as: :article, dependent: :destroy

  validates :title, presence: true, length: {minimum: 10}
  validates :body, presence: true

  scope :asc_by_position, ->{ order('-position DESC, created_at DESC') }

  before_save :sanitize_body
  after_save :reposition, if: 'self.position_changed?'

  mount_uploader :thumbnail, ArticleThumbnailUploader

  attr_accessor :thumbnail_x, :thumbnail_y, :thumbnail_w, :thumbnail_h

  # TODO: extract that to shared module
  def reposition
    if self.position
      unless self.trending_until_changed?
        trending_until = Time.current.advance(hours: (self.position_was.nil? ? 6 : 3))
        update_columns(trending_until: trending_until, updated_at: Time.current)
      end
      schedule_removal_from_trending
      insert_at self.position
    elsif
      update_columns(trending_until: nil, updated_at: Time.current)
    end
  end

  def to_param
    self.slug
  end

  private

  def sanitize_body
    self.body = Sanitize.fragment(self.body, Sanitize::Config.merge(Sanitize::Config::RELAXED,
                                    transformers: SanitizationTransformers.youtube_transformer
                                  ))
  end
end
