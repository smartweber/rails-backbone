class Message < ActiveRecord::Base
  include AttachableByUser

  belongs_to :chat
  belongs_to :participant
  has_many :notifications, as: :notifiable, dependent: :destroy
  validates_presence_of :chat_id, :participant_id
  validates :body, presence: true, length: { minimum: 1 }
  # TODO ensure that chat.participants.include? self.participant_id
  after_commit :delayed_notification, on: :create

  attr_accessor :publication_error

  delegate :user_id, to: :participant, allow_nil: true

  def subscribe_target_participant
    message = self
    target_participant = (self.chat.participants - [self.participant]).first
    self.chat.send_subscribe_message_to(target_participant)
  end

  private

    def delayed_notification
      NotificationWorker.new_message(self.participant.user_id, self.id)
    end
end
