class Comment < ActiveRecord::Base
  include AttachableByUser
  include Likeable
  include Mentionable
  include DestroyableWithDelay

  # TODO: make sure that this record not actually deleted but instead marked as deleted
  # since deletion is a very costly operation unless we're open to leaving hanging key-nullified
  # associations for a future CRON-job deletion
  belongs_to :user
  belongs_to :commentable, polymorphic: true, counter_cache: true
  has_many :likes, as: :likeable, dependent: :destroy
  has_many :replies, class_name: 'Comment', foreign_key: 'reply_to_comment_id'
  validates :body, :commentable_id, :commentable_type, presence: true
  validates_length_of :body, minimum: 3
  after_create :delayed_notification

  default_scope -> { not_scheduled_for_deletion }
  scope :recent, ->(amount) { order('created_at DESC').limit(amount) }
  scope :not_scheduled_for_deletion, -> { where.not(marked_for_deletion: true) }

  private

    def delayed_notification
      target_user_id = commentable.user_id
      NotificationWorker.new_comment(user_id, target_user_id) unless target_user_id == user_id
    end
end
