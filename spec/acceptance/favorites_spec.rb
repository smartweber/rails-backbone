require 'acceptance_helper'

resource 'Favorites', type: :acceptance do
  header 'Accept', 'application/json'
  header 'Content-Type', 'application/json'

  let!(:user) { create(:user) }
  let!(:post) { create(:post) }

  context 'signed in' do
    before do
      no_doc do
        client.post '/login.json', user: { email: user.email, password: user.password }
      end
    end

    post '/api/collection' do
      parameter :post_id, 'ID of post which is to be added to favorites', required: true

      response_field :id, 'Favorite entity id(delete to unfavorite)'

      let(:post_id) { post.id }

      example_request 'Add to favorites' do
        expect(status).to eq(201)
        expect( json['id'] ).to be_eql(Favorite.last.id)
      end

      example 'Add to favorites(not found)', document: false do
        do_request(post_id: nil)
        expect(status).to eq(404)
      end
    end

    delete '/api/collection/:id' do
      before { user.favorite(post) }

      parameter :id, 'ID of post which is to be removed from favorites', required: true

      response_field :id, 'ID of Favorite entity'

      let(:id) { post.id }

      example_request 'Remove from favorites' do
        expect(status).to eq(204)
      end
    end

    get '/api/collection' do
      before { user.favorite(post) }

      parameter :page, 'Pagination page', required: false

      let(:post_excluded_attributes) { %w(content user_id picture friends_only marked_for_deletion article_id article_type updated_at) }
      let(:first_post_user) { post.user }
      let(:user_attributes) { first_post_user.attributes.extract!(*%w(id name username)) }

      example_request "Retrieve favorite posts" do
        expect(status).to eq(200)
        expect( json.first.except!(*post_excluded_attributes) ).to be_eql(
          convert_times(post.reload.attributes).except!(*post_excluded_attributes)
            .merge!(
              'user' => user_attributes.merge!('gravatar_url' => gravatar_url_for(first_post_user, size: 50)),
              'comments' => [],
              'like' => nil,
              'favorited' => true
            )
        )
      end
    end
  end
end
