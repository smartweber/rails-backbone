require 'acceptance_helper'

resource 'Notifications', type: :acceptance do
  header 'Accept', 'application/json'
  header 'Content-Type', 'application/json'

  let!(:user)                 { create(:user) }
  let!(:message_notification) { create(:message_notification, user: user) }

  context 'signed in' do
    before do
      no_doc do
        client.post '/login.json', user: { email: user.email, password: user.password }
      end
    end

    put '/api/notifications/:id' do
      parameter :id, 'ID of notification', required: true
      parameter :seen, 'New status of notification. Shows if notification was seen or not', required: true, scope: :notification

      response_field :id, 'Notification id'
      response_field :seen, 'Indicated whether notification was seen before'
      response_field :type, 'Type of the notificaiton'

      let(:id)   { message_notification.id }
      let(:seen) { true }

      example_request 'Updating notification' do
        expect(status).to eq(200)
        expect( json['id'] ).to be_eql(message_notification.id)
        expect( json['seen'] ).to be_eql(seen)
        expect( json['type'] ).to be_eql(message_notification.notification_type)
      end

      example 'Updating notification(invalid)', document: false do
        do_request(notification: {seen: nil})
        expect(status).to eq(400)
        expect( json['errors'] ).to_not be_empty
      end
    end
  end
end
