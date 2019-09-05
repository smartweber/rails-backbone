require 'acceptance_helper'

resource 'FollowingCompanies', type: :acceptance do
  header 'Accept', 'application/json'
  header 'Content-Type', 'application/json'

  context 'signed in' do
    let(:user) { create(:user) }
    let!(:company) { create(:company) }

    before do
      no_doc do
        client.post '/login.json', user: { email: user.email, password: user.password }
      end
    end

    get '/api/users/:user_id/following/companies', vcr: { cassette_name: 'quotemedia_quotes' } do
      before { user.follow(company) }

      parameter :user_id, 'User ID', required: true

      response_field :id, 'Company id'
      response_field :name, 'Company name'
      response_field :abbr, 'Company name abbreviature(same as on stock markets)'
      response_field :exchange, 'Company stock exchange'
      response_field :followers_count, 'Amount of followers'
      response_field 'relationship[id]', 'Relationship id(following entity, destroy to unfollow)'

      let(:user_id) { user.id }

      example_request "Retrieve companies that user is following" do
        expect(status).to eql(200)
        expect( json.first['id'] ).to be_eql(company.id)
        expect( json.first['name'] ).to be_eql(company.name)
        expect( json.first['abbr'] ).to be_eql(company.abbr)
        expect( json.first['exchange'] ).to be_eql(company.exchange)
        expect( json.first['followers_count'] ).to be_eql(company.followers_count)
        expect( json.first['relationship'] ).to be_nil
      end
    end
  end
end
