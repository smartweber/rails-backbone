class Tag < ActiveRecord::Base
  acts_as_list add_new_at: nil
  include Shuffleable

  TYPES = {hashtags: 1, cashtags: 2, mentiontags: 3}

  has_many :taggings
  has_many :posts, through: :taggings

  after_save :nullify_taggings_counter, if: 'self.mute_until_changed?'

  scope :hashtags_only, ->{ where(tag_type: TYPES[:hashtags]) }
  scope :not_muted, ->{ where('mute_until IS NULL OR mute_until < ?', Time.current) }
  scope :hashtags_by_position, ->{ order('position ASC').where('position IS NOT NULL').hashtags_only.not_muted }
  scope :muted, ->{ where('mute_until > ?', Time.current) }

  def nullify_taggings_counter
    if self.mute_until > Time.current and self.taggings_count > 0
      self.class.update_counters(self.id, taggings_count: -self.taggings_count)
    end
  end

  def to_param
    self.word
  end
end
