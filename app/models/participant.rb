class Participant < ActiveRecord::Base
  belongs_to :user
  belongs_to :chat
  has_many :messages
  validates_presence_of :user_id, :chat_id
  validates_uniqueness_of :user_id, scope: :chat_id
  with_options if: 'self.last_seen_message_id_changed?' do |context|
    context.validate :last_seen_message_id_only_increases
    context.after_update :mark_all_new_message_notification_as_seen, :publish_status_update_to_chat_subscribers
  end

  def last_seen_message_id_increased?
    self.last_seen_message_id_was.nil? or self.last_seen_message_id_was <= self.last_seen_message_id
  end

  private

  def mark_all_new_message_notification_as_seen
    Notification.mark_seen_for(self)
  end

  # @note in order to show that sender message is read update is issued
  def publish_status_update_to_chat_subscribers
    Bayeux.client.publish(self.chat.subscription_path, { participant: self, message_type: 'read_status_update' })
  end

  def last_seen_message_id_only_increases
    unless self.last_seen_message_id_increased?
      errors.add(:last_seen_message_id, 'New value should be bigger than previous')
    end
  end
end
