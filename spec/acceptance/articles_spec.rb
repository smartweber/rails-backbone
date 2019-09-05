require 'acceptance_helper'

resource 'Articles', type: :acceptance do
  header 'Accept', 'application/json'
  header 'Content-Type', 'application/json'

  context 'signed in' do
    let!(:article) { create(:article, position: 1) }
    let(:article_excluded_attributes) { %w(trending_until updated_at thumbnail) }
    let(:user) { create(:user) }

    before do
      no_doc do
        client.post '/login.json', user: { email: user.email, password: user.password }
      end
    end

    get '/api/articles' do
      response_field :id, 'Article ID'
      response_field :title, 'Article title'
      response_field :body, 'Article body'
      response_field :posts_count, 'Amount of posts associated with article'
      response_field :position, 'Position of article'
      response_field :created_at, 'DateTime when article was created at'

      example_request "Getting a list of articles" do
        expect(status).to eq(200)
        expect( json.first ).to be_eql( convert_times(article.reload.attributes).except!(*article_excluded_attributes) )
      end
    end

    get '/api/articles/:id' do
      parameter :id, 'ID of Article to retrieve', required: true

      response_field :id, 'Article ID'
      response_field :title, 'Article title'
      response_field :body, 'Article body'
      response_field :posts_count, 'Amount of posts associated with article'
      response_field :position, 'Position of article'
      response_field :created_at, 'DateTime when article was created at'

      let(:id) { article.id }

      example_request "Getting a specific article" do
        expect(status).to eq(200)
        expect( json ).to be_eql( convert_times(article.reload.attributes).except!(*article_excluded_attributes) )
      end
    end

    get '/api/articles/:id/feed' do
      parameter :id, 'ID of Article', required: true

      let(:id) { article.id }

      it_behaves_like "feed", "Retrieving feed associated with an article"
    end
  end
end
