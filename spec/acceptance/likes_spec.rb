require 'acceptance_helper'

resource 'Likes', type: :acceptance do
  header 'Accept', 'application/json'
  header 'Content-Type', 'application/json'

  let!(:user)    { create(:user) }
  let!(:friend)  { create(:user) }
  let!(:post)    { create(:post) }
  let!(:like)    { create(:like, user: user) }
  let!(:comment) { create(:comment) }

  context 'signed in' do
    let(:likeable_id)   { comment.id }
    let(:likeable_type) { comment.class.to_s }

    before do
      no_doc do
        client.post '/login.json', user: { email: user.email, password: user.password }
      end
    end

    post '/api/likes' do
      parameter :likeable_id, 'ID of entity to like', required: true, scope: :like
      parameter :likeable_type, 'Type of entity to like', required: true, scope: :like

      response_field :id, 'Like id'
      response_field :likeable_id, 'Likeable entity id(one that\'s been liked)'
      response_field :likeable_type, 'Likeable entity type'

      example_request 'Create a like' do
        expect(status).to eq(201)
        expect( json['id'] ).to be_eql(Like.last.id)
        expect( json['likeable_id'] ).to be_eql(Like.last.likeable_id)
        expect( json['likeable_type'] ).to be_eql(Like.last.likeable_type)
      end

      example 'Create a like(invalid)', document: false do
        do_request(like: {likeable_id: nil})
        expect(status).to eq(400)
        expect( json['errors'] ).to_not be_empty
      end
    end

    delete '/api/likes/:id' do
      before { Like.create(likeable_id: likeable_id, likeable_type: likeable_type) }

      parameter :id, 'ID of like entity to destroy', required: true

      let(:id) { like.id }

      example_request 'Delete a like' do
        expect(status).to eq(204)
      end
    end
  end
end
