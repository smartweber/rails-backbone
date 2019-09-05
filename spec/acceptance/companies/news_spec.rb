require 'acceptance_helper'

resource 'CompanyNews', type: :acceptance do
  header 'Accept', 'application/json'
  header 'Content-Type', 'application/json'

  context 'signed in' do
    let(:user) { create(:user) }

    before do
      no_doc do
        client.post '/login.json', user: { email: user.email, password: user.password }
      end
    end

    get '/api/c/:company_id/news', vcr: { cassette_name: 'yahoo_finance' } do
      parameter :company_id, 'Company ID', required: true

      response_field :id, 'NewsItem ID'
      response_field :url, 'NewsItem url'
      response_field :title, 'NewsItem title'
      response_field :published_at, 'NewsItem published_at'

      let!(:company_news_item) { create(:company_news_item) }
      let(:company_id) { company_news_item.company.abbr }

      example_request 'Retrieve company news' do
        expect(status).to eql(200)
        expect( json.first['id'] ).to be_eql(company_news_item.id)
        expect( json.first['url'] ).to be_eql(company_news_item.url)
        expect( json.first['title'] ).to be_eql(company_news_item.title)
        expect( json.first['published_at'] ).to be_eql(company_news_item.reload.published_at.to_json.gsub("\"", ''))
      end
    end
  end
end
