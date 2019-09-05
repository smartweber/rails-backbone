class Tagging < ActiveRecord::Base
  belongs_to :post
  belongs_to :tag, counter_cache: :taggings_count

  scope :by_tags, ->(tags) { joins(:tag).where('tags.word IN (?)', tags).order('created_at DESC') }
  scope :recent_by_tags, ->(tags, timepoint) { joins(:tag, :post).where('tags.word IN (?) AND posts.created_at > ?', tags, timepoint).order('created_at DESC') }

  def self.latest_posts_by_tags(tags)
    by_tags(tags).limit(8).map(&:post).reject(&:nil?)
  end

  def self.recent_posts_by_tags(tags, timepoint)
    recent_by_tags(tags, timepoint).limit(9).map(&:post).reject(&:nil?)
  end
end
