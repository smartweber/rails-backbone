require 'acceptance_helper'

resource 'Chats', type: :acceptance do
  header 'Accept', 'application/json'
  header 'Content-Type', 'application/json'

  let(:chat) { create(:chat) }

  context 'signed in' do
    before do
      @participant = chat.participants.last
      @attachment  = create(:image_attachment, attachable: chat.messages.last, user: @participant.user)
      @user        = @participant.user
      no_doc do
        client.post '/login.json', user: { email: @user.email, password: @user.password }
      end
    end

    get '/api/chats' do
      response_field :id, 'Chat id'
      response_field 'participants[id]', 'Participant id'
      response_field 'participants[user_id]', 'User id of participant entity'
      response_field 'participants[chat_id]', 'Chat id of participant entity'
      response_field 'messages[]', 'See POST /messages documentation for a structure'

      example_request "Getting a list of chats" do
        explanation "Every chat object has just one, last message, embedded"

        expect(status).to eq(200)
        expect( json.first['id'] ).to be_eql(chat.id)
        expect( json.first['participants'] ).to be_eql(chat.participants.map{|p| p.attributes.except('updated_at', 'created_at').merge({'user' => { 'name' => p.user.name }})})
        expect( json.first['messages'].map{|m| m.except('user', 'attachments', 'created_at')} ).to be_eql([chat.messages.last.attributes.except('updated_at', 'created_at')])
        expect( json.first['messages'].first['user'].except('gravatar_url') ).to be_eql(chat.messages.last.participant.user.attributes.extract!('id', 'name', 'username').merge({'relationship' => nil}))
        expect( json.first['messages'].first['attachments'].first.except('image_url') ).to be_eql(@attachment.attributes.except('image', 'attachable_id', 'attachable_type', 'admin_user_id'))
        expect( json.first['messages'].first['attachments'].first['image_url'] ).to be_eql(@attachment.image_url)
      end
    end

  end
end
