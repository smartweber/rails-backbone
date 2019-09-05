class Like < ActiveRecord::Base
  belongs_to :user
  belongs_to :likeable, polymorphic: true, counter_cache: true
  has_one :notification, as: :notifiable, dependent: :destroy
  validates_presence_of :likeable_type, :likeable_id
  validates_uniqueness_of :likeable_type, scope: :likeable_id
  after_create :delayed_notification

  private

    def delayed_notification
      unless likeable && user_id == likeable.user_id
        NotificationWorker.post_liked(self.id)
      end
    end
end
