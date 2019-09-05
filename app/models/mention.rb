class Mention < ActiveRecord::Base
  belongs_to :user
  belongs_to :mentionable, polymorphic: true

  after_create :delayed_notification

  private

    def delayed_notification
      NotificationWorker.new_mention( self.mentionable.user_id, self.id )
    end
end
