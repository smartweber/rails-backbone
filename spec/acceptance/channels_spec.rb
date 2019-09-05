require 'acceptance_helper'
require 'application_helper'
require 'users_helper'

resource 'Channels', type: :acceptance do
  include ActionView::Helpers::UrlHelper

  header 'Accept', 'application/json'
  header 'Content-Type', 'application/json'

  let!(:user) { create(:user) }
  let(:hashtag) { 'hashtag' }
  let!(:post)  { create(:post, content: "##{hashtag} is being mentioned") }

  before { Tag.last.insert_at 1 }

  context 'signed in' do
    before do
      no_doc do
        client.post '/login.json', user: { email: user.email, password: user.password }
      end
    end

    get '/api/channels/:id' do
      parameter :id, 'Channel name(hashtag) without # sign', required: true

      response_field :id, 'Post id'
      response_field :created_at, 'DateTime post was created at'
      response_field :comments_count, 'Amount of comments for a post'
      response_field :content, 'Post content(with $/@/# wrapped into links)'
      response_field :favorited, 'Favorite entity id(delete to unfavorite)'
      response_field 'user[id]', 'Id of user that\'s created post'
      response_field 'user[name]', 'Name of the creator'
      response_field 'user[gravatar_url]', 'Url for gravatar image'
      response_field 'comments[]', 'See POST /comments for a description'

      let(:id) { "#{hashtag}" }

      it_behaves_like "feed", "Retrieving #hashtag mentioning posts"

      example 'Retrieving posts for non-existent channel(invalid)', document: false do
        do_request(id: 'fairytail')
        expect(status).to eq(404)
      end
    end

    get '/api/channels' do
      parameter :limit, 'How many hashtags to retrieve', required: true

      response_field :id, 'Tag id'
      response_field :word, 'Channel name'
      response_field :description, 'Description of channel'
      response_field :taggings_count, 'How many items are tagged with this tag'

      let(:limit) { 5 }

      example_request 'Retrieving top hashtags(channels)' do
        expect(status).to eq(200)
        expect( json.first['id'] ).to be_eql(Tag.last.id)
        expect( json.first['word'] ).to be_eql(Tag.last.word)
        expect( json.first['description'] ).to be_eql(Tag.last.description)
        expect( json.first['taggings_count'] ).to be_eql(Tag.last.taggings_count)
        expect( json.size ).to be_eql(1)
      end
    end
  end
end
