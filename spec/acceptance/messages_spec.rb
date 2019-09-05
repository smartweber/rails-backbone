require 'acceptance_helper'

resource 'Messages', type: :acceptance do
  header 'Accept', 'application/json'
  header 'Content-Type', 'application/json'

  let!(:target_user) { create(:user) }
  let!(:chat)        { create(:chat) }
  let(:message)      { build(:message) }
  let(:user_attachment)   { create(:user_attachment, attachable: nil, user: user) }
  let(:user_attachments) {
    { id: attachment.id }
  }
  let(:user)        { chat.participants.first.user }

  context 'signed in' do
    before do
      no_doc do
        client.post '/login.json', user: { email: user.email, password: user.password }
      end
    end

    post '/api/messages' do
      parameter :username, 'User that\'s to receive a message', required: true, scope: :message
      parameter :body, 'Content of the message', required: true, scope: :message
      parameter :id, 'ID of attachment', scope: :message

      response_field 'id', 'Id if message'
      response_field 'body', 'Body(content) of message'
      response_field 'chat_id', 'Chat id of message'
      response_field 'created_at', 'DateTime at which message was created'
      response_field 'user[id]', 'User id of the messages creator'
      response_field 'user[name]', 'Name of the messages creator'
      response_field 'user[username]', 'Username of the messages creator'
      response_field 'user[gravatar_url]', 'Gravatar url of the messages creator'
      response_field 'attachments[id]', 'Id of the attachment'
      response_field 'attachments[type_of_attachment]', "'image' or 'link'"
      response_field 'attachments[title]', "Title of the 'link' attachment"
      response_field 'attachments[description]', "Description of the 'link' attachment"
      response_field 'attachments[image_url]', "Url of image(if any)"
      response_field 'attachments[user_id]', "User that created attachment"

      let(:username) { target_user.username }
      let(:body) { message.body }
      let(:last_message) { Message.last }
      let(:id) { 2 }

      example_request 'Create message' do
        explanation 'Being used only once for each new chat(creates chats by first message).
                     Please do not use this endpoint response data-object in the app'

        expect(status).to be_eql 201
        expect( json['id'] ).to be_eql( last_message.id )
        expect( json['body'] ).to be_eql( last_message.body )
        expect( json['chat_id'] ).to be_eql( last_message.chat_id )
        expect( json['participant_id'] ).to be_eql( last_message.participant_id )
        expect( json['attachments'] ).to be_eql( [] )
      end

    end

    get '/api/chats/:chat_id/messages' do
      let!(:user_attachment) { create(:image_attachment, attachable: chat.messages.last, user: chat.participants.last.user) }

      parameter :chat_id, 'ID of chat to fetch messages for', required: true
      parameter :page, 'Determines offset for a returned messages(pagination)'

      let(:page) { 1 }
      let(:chat_id) { chat.id }

      example_request 'Listing messages' do
        explanation 'Individual objects are identical to those in POST /messages'

        expect(status).to be_eql 200
        expect( json.map{|m| m.except('user', 'attachments', 'created_at')} ).to be_eql(chat.messages.order('created_at DESC').map{|m| m.attributes.except('updated_at', 'created_at')}.reverse)
        expect( json.first['user'].except('gravatar_url') ).to be_eql(chat.messages.reverse.first.participant.user.attributes.extract!('id', 'name', 'username').merge({'relationship' => nil}))
        expect( json.first['attachments'].first.except('image_url') ).to be_eql(user_attachment.attributes.except('image', 'attachable_id', 'attachable_type', 'admin_user_id'))
        expect( json.first['attachments'].first['image_url'] ).to be_eql(user_attachment.image_url)
      end
    end
  end
end
