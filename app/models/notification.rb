class Notification < ActiveRecord::Base
  include RablHelper

  MESSAGE = %w(new_message)
  COMMON  = %w(new_follower post_liked new_comment new_mention)
  STOCK   = %w(stock_news)
  # Be aware that type is used for rabl template finding(see views/users/notifications)
  TYPES   = MESSAGE + COMMON + STOCK

  belongs_to :notifiable, polymorphic: true
  belongs_to :user

  validates_presence_of :user_id
  validates :seen, inclusion: { in: [true, false] }
  validates_presence_of :notifiable_id, :notifiable_type, if: :notifiable_required?

  after_create :send_notifying_email, if: 'self.user.notification_subscription'
  after_create :mark_previous_notifications_as_seen, unless: 'self.notification_type == "new_message"'
  after_update :mark_previous_notifications_as_seen, if: 'self.notification_type == "new_message"'

  # TODO: ensure that notification will be uniq for given user_id/notifiable/notification_type
  default_scope -> { order('created_at DESC') }
  scope :unseen, ->{ where(seen: false) }
  scope :with_message_type, ->{ one_message_per_chat.where(notification_type: MESSAGE) }
  scope :with_common_type,    ->{ where(notification_type: COMMON) }
  scope :with_stock_type,     ->{ where(notification_type: STOCK) }
  scope :join_on_messages,    ->{ joins('INNER JOIN messages ON messages.id = notifications.notifiable_id') }
  scope :same_type_as,        ->(notification) { where(notification_type: notification.notification_type,
    user_id: notification.user_id, notifiable_type: notification.notifiable_type) }
  scope :since,               ->(start_time) { where(created_at: start_time..Time.now) }

  %w(new_follower new_comment).each do |method_name|
    define_singleton_method(method_name.to_sym) do |source_user_id, target_user_id|
      # TODO: validate that notifiable obj exists
      notification = create( user_id: target_user_id, notifiable_id: source_user_id,
                            notifiable_type: 'User', notification_type: method_name )
      notification.publish_to(target_user_id)
    end
  end

  def self.post_liked( like_id )
    notification_type = 'post_liked'
    like = Like.where(id: like_id).first
    if like
      source_user_id = like.user_id
      # in other words: owner of object that's been liked
      target_user_id = like.likeable.user_id
      notification = create( user_id: target_user_id, notifiable: like, notification_type: notification_type )
      notification.publish_to(target_user_id)
    end
  end

  def self.new_message( source_user_id, message_id )
    notification_type = 'new_message'
    message           = Message.where(id: message_id).first
    if message
      target_user_ids = message.chat.participants.map(&:user_id)
      target_user_ids.delete(source_user_id)
      target_user_ids.each do |target_user_id|
        notification = create( user_id: target_user_id, notifiable_id: message.id,
                              notifiable_type: 'Message', notification_type: notification_type )
        notification.publish_to(target_user_id)
      end
    end
  end

  def self.new_mention( source_user_id, mention_id )
    notification_type = 'new_mention'
    mention = Mention.where(id: mention_id).first
    if mention
      notification = create( user_id: mention.user_id, notifiable: mention.mentionable,
                            notification_type: notification_type )
      notification.publish_to(mention.user_id)
    end
  end

  def self.stock_news

  end

  def self.mark_seen_for(participant)
    participant_notifications = Notification.join_on_messages.unseen.where(notifiable_type: 'new_message',
                                  user_id: participant.user_id, messages: { chat_id: participant.chat_id })
    Notification.mark_seen(participant_notifications)
  end

  def self.mark_seen(notifications)
    notifications.each do |notification|
      notification.seen!
    end
  end

  def publish_to(target_user_id)
    if self.persisted?
      obj = RablHelper.render('api/users/notifications/_notification', self)
      self.publish(target_user_id, obj)
    end
  end

  def publish(target_user_id, message)
    Bayeux.client.publish( Rails.application.routes.url_helpers.notifications_api_user_path(target_user_id), message )
  end

  def seen!
    self.update_attribute(:seen, true)
  end

  def self.one_message_per_chat
    joins('LEFT JOIN messages ON messages.id = notifications.notifiable_id').group('messages.chat_id')
  end

  def other_recent_activity_participants
    unless ['new_follower', 'post_liked', 'new_comment'].include?(self.notification_type)
      raise "Notification type is invalid for this method"
    end
    user_notifiable = ->(e){ e.id == self.notifiable.id }
    like_notifiable = ->(e){ e.user_id == self.notifiable.user_id }
    arr = Notification.same_type_as(self).since(Time.now.advance(minutes: -30)).map(&:notifiable).uniq
    self.notification_type == 'post_liked' ? arr.reject(&like_notifiable).map(&:user) : arr.reject(&user_notifiable)
  end

  def send_notifying_email
    NotificationMailer.new_notification_email(self.user_id, self.id).deliver_later
  end

  private

  def mark_previous_notifications_as_seen
    same_notifications = unless self.notification_type == 'new_message'
      Notification.where.not(id: self.id).unseen.where(notifiable_type: self.notifiable_type,
        notifiable_id: self.notifiable_id, notification_type: self.notification_type)
    else
      Notification.join_on_messages.unseen.where(notifiable_type: self.notifiable_type,
                   user_id: self.user_id, messages: { chat_id: self.notifiable.chat_id })
    end
    Notification.mark_seen(same_notifications)
  end

  def notifiable_required?
    true
  end
end
