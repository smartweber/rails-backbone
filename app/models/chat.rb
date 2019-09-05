class Chat < ActiveRecord::Base
  include RablHelper

  has_many :participants, dependent: :destroy
  has_many :messages, dependent: :destroy

  def messages_by_page( page )
    if page == 1
      latest
    else
      page(page)
    end
  end

  def self.find_or_build( *users )
    chats = find_with_participants( *users )
    chats.empty? ? new : chats.first
  end

  def self.find_with_participants( *users )
    participants = Participant.find_by_sql ['SELECT * FROM participants t1
                                           INNER JOIN participants t2 ON t1.chat_id = t2.chat_id
                                           WHERE t1.user_id = ? AND t2.user_id = ?', users.first.id, users.last.id ]
    participants.empty? ? [] : [participants.first.chat]
  end

  def add_participants( *users )
    users.each{|u| add_participant(u) }
  end

  def add_participant( user )
    self.participants.create( user: user )
  end

  def subscription_path
    Rails.application.routes.url_helpers.api_chat_messages_path(self.id)
  end

  def latest
    # Redis fetching here
  end

  def send_subscribe_message_to(participant)
    chat_json = RablHelper.render('api/chats/_base', self)

    Bayeux.client.publish(Rails.application.routes.url_helpers.subscriptions_api_user_path(participant.user_id),
                          { chat: chat_json, subscription_path: self.subscription_path })
  end
end
