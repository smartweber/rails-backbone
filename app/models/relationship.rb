class Relationship < ActiveRecord::Base
  FOLLOWABLE_TYPES = %w(User Company)

  belongs_to :follower, class_name: "User"
  belongs_to :followable, polymorphic: true
  validates_presence_of :follower_id, :followable_id
  validates_uniqueness_of :follower_id, scope: [:followable_id, :followable_type]
  validates_inclusion_of :followable_type, in: FOLLOWABLE_TYPES
  after_create :delayed_notification, if: "followable_type == 'User'"

  private

    def delayed_notification
      NotificationWorker.new_follower(follower_id, followable_id)
    end
end
