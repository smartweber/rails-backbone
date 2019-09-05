require 'acceptance_helper'
require 'application_helper'
require 'users_helper'

resource 'Posts', type: :acceptance do
  header 'Accept', 'application/json'
  header 'Content-Type', 'application/json'

  let!(:user) { create(:user) }
  let(:post)  { create(:post, user: user) }

  context 'signed in' do
    before do
      no_doc do
        client.post '/login.json', user: { email: user.email, password: user.password }
      end
    end

    post '/api/posts' do
      parameter :content, 'Content of post', required: true, scope: :post
      parameter :friends_only, 'Whether this post is only shown for a friends', scope: :post

      response_field :id, 'Post id'
      response_field :created_at, 'DateTime post was created at'
      response_field :comments_count, 'Amount of comments for a post'
      response_field :content, 'Post content(with $/@/# wrapped into links)'
      response_field :favorited, 'Favorite entity id(delete to unfavorite)'
      response_field :likes_count, 'Cached amount of likes'
      response_field :like, 'DEPRECATED'
      response_field 'user[id]', 'Id of user that\'s created post'
      response_field 'user[name]', 'Name of the creator'
      response_field 'user[gravatar_url]', 'Url for gravatar image'
      response_field 'comments[]', 'See POST /comments for a description'

      let(:content) { Faker::Lorem.sentence }
      let(:friends_only) { true }

      example_request 'Creating a post' do
        expect(status).to eq(201)
        expect( json['id'] ).to be_eql(Post.last.id)
        expect( json['comments_count'] ).to be_eql(Post.last.comments_count)
        expect( json['content'] ).to be_eql(convert_specials_to_links(Post.last.content))
        expect( json['favorited'] ).to be_falsey
        expect( json['likes_count'] ).to be_eql(0)
        expect( json['like'] ).to be_eql(nil)
        expect( json['user']['id'] ).to be_eql(Post.last.user_id)
        expect( json['user']['name'] ).to be_eql(Post.last.user.name)
        expect( json['user']['comments'] ).to be_nil
      end

      example 'Creating a post(invalid)', document: false do
        do_request(post: { content: '' })
        expect(status).to eq(400)
        expect( json['errors'] ).to_not be_empty
      end
    end

    delete '/api/posts/:id' do
      parameter :id, 'ID of post to delete', required: true

      let(:id) { post.id }

      example_request 'Deleting a post' do
        expect(status).to eq(204)
      end
    end

    get '/api/posts/trending' do
      let!(:trending_company) { create(:trending_company) }
      let!(:post_with_company_mention) { create(:post, content: "Something about ##{trending_company.abbr}") }

      it_behaves_like 'feed', "Retrieving trending posts feed"
    end
  end
end
