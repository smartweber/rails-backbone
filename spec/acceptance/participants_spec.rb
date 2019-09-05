require 'acceptance_helper'

resource 'Notifications', type: :acceptance do
  header 'Accept', 'application/json'
  header 'Content-Type', 'application/json'

  let!(:user)        { create(:user) }
  let!(:participant) { create(:participant, user: user) }

  context 'signed in' do
    before do
      no_doc do
        client.post '/login.json', user: { email: user.email, password: user.password }
      end
    end

    put '/api/participants/:id' do
      parameter :id, 'Participant ID', required: true
      parameter :last_seen_message_id, 'ID of the last message that participant have seen', scope: :participant

      response_field :id, 'Participant ID'
      response_field :user_id, 'User ID of user behind Participant'
      response_field :chat_id, 'ID of chat that participant is participating at'
      response_field :last_seen_message_id, 'ID of the last message that participant have seen'
      response_field 'user[name]', 'Name of the User behind participant'

      let(:except_attributes) { %w(created_at updated_at) }
      let(:id) { participant.id }

      example "Updates participant's last_seen_message_id" do
        do_request(participant: { last_seen_message_id: participant.chat.messages.last.id })
        expect(status).to eql(200)
        expect( json.except(*except_attributes) ).to be_eql(participant.reload.attributes.except(*except_attributes).merge(
                                                            'user' => {
                                                                'name' => user.name
                                                              }))
      end
    end
  end
end
