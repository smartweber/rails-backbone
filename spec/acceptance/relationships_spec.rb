require 'acceptance_helper'

resource 'Relationships', type: :acceptance do
  header 'Accept', 'application/json'
  header 'Content-Type', 'application/json'

  let!(:user)            { create(:user) }
  let!(:followable_user) { create(:user) }
  let(:post)             { create(:post, user: user) }

  context 'signed in' do
    before do
      no_doc do
        client.post '/login.json', user: { email: user.email, password: user.password }
      end
    end

    post '/api/relationships' do
      parameter :followable_id, 'ID of object that\'s to be followed', required: true
      parameter :followable_type, 'Type of object that\'s to be followed', required: true

      response_field :id, 'Relationship id'

      let(:followable_id) { followable_user.id }
      let(:followable_type) { followable_user.class.to_s }

      example_request 'Creating a relationship' do
        expect(status).to eq(201)
        expect( json['id'] ).to be_eql(Relationship.last.id)
      end

      example 'Creating a relationship(invalid)', document: false do
        do_request(followable_id: nil)
        expect(status).to eq(400)
        expect( json['errors'] ).to_not be_empty
      end
    end

    delete '/api/relationships/:id' do
      before { user.follow(followable_user) }

      parameter :id, 'ID of Relationship that\'s to be destroyed', required: true

      let(:id) { user.active_relationships.first.id }

      example_request 'Delete Relationship' do
        expect(status).to eq(204)
      end
    end
  end
end
