require 'acceptance_helper'

resource 'Recommendations', type: :acceptance do
  header 'Accept', 'application/json'
  header 'Content-Type', 'application/json'

  let!(:user) { create(:user) }
  let!(:company)  { create(:company) }

  context 'signed in' do
    before do
      no_doc do
        client.post '/login.json', user: { email: user.email, password: user.password }
      end
    end

    get '/api/users/:id/recommendations/companies' do
      parameter :id, 'User id', required: true

      let(:id) { create(:user).id }

      example "Getting list of recommended companies" do
        do_request(id: id)
        expect(status).to eq(200)
        expect( json.first['id'] ).to be_eql(company.id)
        expect( json.first['name'] ).to be_eql(company.name)
        expect( json.first['abbr'] ).to be_eql(company.abbr)
        expect( json.first['target_url'] ).to be_eql(company_path(company.abbr))
        expect( json.first['followers_count'] ).to be_eql(company.followers_count)
        expect( json.first['relationship'] ).to be_nil
      end

    end
  end

end
