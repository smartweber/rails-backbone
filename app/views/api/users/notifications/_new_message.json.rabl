child(:notifiable => :notifiable) do |notifiable|
  attributes :id, :body, :chat_id, :created_at

  node :user do |m|
    partial('api/users/_base', object: m.participant.user)
  end

  node :attachments do |m|
    partial('api/shared/_attachment_base', object: m.attachments.first)
  end
end
