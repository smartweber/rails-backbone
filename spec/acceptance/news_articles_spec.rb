require 'acceptance_helper'

resource 'News', type: :acceptance do
  header 'Accept', 'application/json'
  header 'Content-Type', 'application/json'

  context 'signed in', vcr: { cassette_name: 'google_image_search' } do
    let!(:news_article) { create(:positioned_general_news_item) }
    let(:thumbnail_hash) { {'news_thumbnail_stretched_full_url' => news_article.news_thumbnail_stretched_full_url,
                            'news_thumbnail_carousel_list_url' => news_article.news_thumbnail_carousel_list_url } }
    let(:user) { create(:user) }
    let(:excepted_attributes) { %w(summary title sanitized_summary) }
    let(:news_article_extracted_attributes) { %w(id url agency locally_hosted slug) }

    before { @posts = create_list(:post, 2, article_id: news_article.id, article_type: 'GeneralNewsItem') }
    before do
      no_doc do
        client.post '/login.json', user: { email: user.email, password: user.password }
      end
    end

    get '/api/news_articles' do
      response_field :id, 'News article ID'
      response_field :url, 'Url to external news article'
      response_field :title, 'Title of news article'
      response_field :summary, 'Truncated summary of news article'
      response_field :sanitized_summary, 'Truncated sanitized(strict) summary of news article'
      response_field :agency, 'See app_config.yml for agency types'
      response_field :slug, 'Friendly URL'

      example_request "Getting a list of news articles" do
        expect(status).to eq(200)
        expect( json.first.except(*excepted_attributes) ).to be_eql(news_article.attributes.extract!(*news_article_extracted_attributes).merge(thumbnail_hash))
        expect( json.first['title'] ).to be_eql(news_article.title.truncate(120))
        expect( json.first['summary'] ).to be_eql(news_article.summary.truncate(200))
        expect( json.first['sanitized_summary'] ).to be_eql(news_article.sanitized_summary.truncate(200))
      end
    end

    get '/api/news_articles/ranged' do
      parameter :lowBorder, 'Minimal position', require: true
      parameter :highBorder, 'Maximal position', require: true

      response_field :id, 'News article ID'
      response_field :url, 'Url to external news article'
      response_field :title, 'Title of news article'
      response_field :summary, 'Truncated summary of news article'
      response_field :sanitized_summary, 'Truncated sanitized(strict) summary of news article'
      response_field :agency, 'See app_config.yml for agency types'
      response_field :slug, 'Friendly URL'

      let(:lowBorder) { 1 }
      let(:highBorder) { 2 }

      example_request "Retrieve news articles ranged by position" do
        expect(status).to eq(200)
        expect( json.first.except(*excepted_attributes) ).to be_eql(news_article.attributes.extract!(*news_article_extracted_attributes).merge(thumbnail_hash))
        expect( json.first['title'] ).to be_eql(news_article.title.truncate(120))
        expect( json.first['summary'] ).to be_eql(news_article.summary.truncate(200))
        expect( json.first['sanitized_summary'] ).to be_eql(news_article.sanitized_summary.truncate(200))
      end
    end

    get '/api/news_articles/:id' do
      parameter :id, 'ID of NewsArticle to retrieve', required: true

      response_field :id, 'News article ID'
      response_field :url, 'Url to external news article'
      response_field :title, 'Title of news article'
      response_field :summary, 'Truncated summary of news article'
      response_field :sanitized_summary, 'Truncated sanitized(strict) summary of news article'
      response_field :agency, 'See app_config.yml for agency types'
      response_field :slug, 'Friendly URL'

      let(:id) { news_article.id }

      example_request "Getting a specific article" do
        expect(status).to eq(200)
        expect( json.except(*excepted_attributes) ).to be_eql( news_article.attributes.extract!(*news_article_extracted_attributes).merge(thumbnail_hash) )
      end
    end

    get '/api/news_articles/:id/feed' do
      parameter :id, 'ID of NewsArticle', required: true

      let(:id) { news_article.id }

      it_behaves_like "feed", "Retrieving feed associated with an news article", @posts
    end

  end
end
