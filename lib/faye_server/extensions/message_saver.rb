class MessageSaver
  include RablHelper

  def incoming(message, request, callback)
    # TODO: poorly written, should be better way
    if message['channel'] =~ /\/api\/chats\/[0-9]+\/messages/ and message['error'].nil? and message['data']['message_type'].nil?
      attributes      = message['data']['message']
      attachment_ids  = attributes["attachment_ids"].try(:any?) ? attributes["attachment_ids"] : []
      raw_attachments = attributes["attachments"].try(:any?) ? attributes["attachments"] : []
      participant     = Participant.where(chat_id: message["data"]["message"]["chat_id"],
                                         user_id: message["data"]["user_id"]).first
      if participant
        message_obj = Message.create(body: attributes['body'], chat_id: attributes['chat_id'], attachments: raw_attachments,
                                     attachment_ids: attachment_ids, participant: participant)
        if message_obj.persisted?
          message["data"]["message"] = RablHelper.render('api/messages/_base', message_obj)
        else
          message['error'] = '400::Bad request'
        end
      else
        message['error'] = '400::Bad request'
      end

      p "Saver:"
      p message_obj
    end
    callback.call(message)
  end
end
