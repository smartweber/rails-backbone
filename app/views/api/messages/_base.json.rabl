attributes :id, :body, :created_at, :chat_id, :participant_id

unless @skip_user
  node :user do |m|
    partial('api/users/_base', object: m.participant.user)
  end
end

child(:attachments) do
  extends "api/shared/_attachment_base"
end
