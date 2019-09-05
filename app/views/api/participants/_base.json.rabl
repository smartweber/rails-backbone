attributes :id, :user_id, :chat_id, :last_seen_message_id

child(:user) do
  attribute :name
end
