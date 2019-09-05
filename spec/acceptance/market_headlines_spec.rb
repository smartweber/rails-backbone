require 'acceptance_helper'

resource 'MarketHeadlines', type: :acceptance do
  header 'Accept', 'application/json'
  header 'Content-Type', 'application/json'

  context 'signed in' do
    let(:user) { create(:user) }

    before do
      no_doc do
        client.post '/login.json', user: { email: user.email, password: user.password }
      end
    end

    get '/api/market_headlines' do
      response_field :id, 'Market Headline ID'
      response_field :title, 'Market Headline title'
      response_field :position, 'Market Headline position'

      let!(:market_headlines) { create_list(:market_headline, 2) }

      example_request "Retrieve market headlines news" do
        expect(status).to eql(200)
        expect( json.first['id'] ).to be_eql(market_headlines.first.id)
        expect( json.first['title'] ).to be_eql(market_headlines.first.title)
        expect( json.first['position'] ).to be_eql(market_headlines.first.position)
      end
    end
  end
end
