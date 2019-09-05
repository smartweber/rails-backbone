attributes :id

node :messages do |chat|
  partial 'api/messages/index', object: [chat.messages.last]
end

child :participants do
  extends('api/participants/_base')
end
