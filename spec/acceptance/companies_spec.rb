require 'acceptance_helper'

resource 'Companies', type: :acceptance do
  header 'Accept', 'application/json'
  header 'Content-Type', 'application/json'

  let!(:user)     { create(:user) }
  let!(:company)  { create(:trending_company, abbr: Company::COMPOSITE_INDEXES_ABBREVIATIONS.first) }
  let!(:other_company) { create(:company) }
  let(:company_expectations) do
    lambda do |json_object|
      expect(status).to eq(200)
      expect( json_object['id'] ).to be_eql(company.id)
      expect( json_object['name'] ).to be_eql(company.name)
      expect( json_object['abbr'] ).to be_eql(company.abbr)
      expect( json_object['exchange'] ).to be_eql(company.exchange)
      expect( json_object['followers_count'] ).to be_eql(company.followers_count)
      expect( json_object['relationship'] ).to be_nil
    end
  end

  context 'signed in', vcr: { cassette_name: 'company_page' } do
    before do
      no_doc do
        client.post '/login.json', user: { email: user.email, password: user.password }
      end
    end

    get '/api/c' do
      parameter :query, 'First symbols(at least 1) of abbreviature', required: true

      response_field :target_url, 'Company page URL'

      let(:query) { company.abbr.first(1) }

      example_request "Retrieving a list of companies" do
        explanation "See 'Retrieving a specific company' for response structure explanation"

        company_expectations.call(json.first)
        expect( json.first['target_url'] ).to be_eql(company_path(company.abbr))
      end

      example "Retrieving a list of companies(not found)", document: false do
        do_request(query: '')
        expect(status).to eq(200)
      end

    end

    get '/api/c/:id' do
      parameter :id, 'Abbreviature of company', required: true

      response_field :id, 'Company id'
      response_field :name, 'Company name'
      response_field :abbr, 'Company name abbreviature(same as on stock markets)'
      response_field :exchange, 'Company stock exchange'
      response_field :followers_count, 'Amount of followers'
      response_field 'relationship[id]', 'Relationship id(following entity, destroy to unfollow)'

      let(:id) { company.abbr }

      example_request "Retrieving a specific company" do
        company_expectations.call(json)
      end

      example "Retrieving a specific company(not found)", document: false do
        do_request(id: 'UNKNOWN')
        expect(status).to eq(404)
      end
    end

    context "with trending companies" do
      get '/api/c/trending' do
        response_field :id, 'Company id'
        response_field :name, 'Company name'
        response_field :abbr, 'Company name abbreviature(same as on stock markets)'
        response_field :exchange, 'Company stock exchange'
        response_field :target_url, 'Company page URL'
        response_field :followers_count, 'Amount of followers'

        example_request "Retrieving trending companies" do
          company_expectations.call(json.first)
        end
      end
    end

    context "with composite indexes" do
      get '/api/c/market_snapshot' do
        response_field :id, 'Company id'
        response_field :name, 'Company name'
        response_field :abbr, 'Company name abbreviature(same as on stock markets)'
        response_field :exchange, 'Company stock exchange'
        response_field :target_url, 'Company page URL'
        response_field :followers_count, 'Amount of followers'

        example_request "Retrieving a list of composite indexes" do
          company_expectations.call(json.first)
        end
      end
    end

    context "with company that user follows" do
      before { user.follow(company) }

      get '/api/users/:user_id/following/companies' do
        parameter :user_id, 'User id of user for whom we retrieving following companies', required: true

        response_field :id, 'Company id'
        response_field :name, 'Company name'
        response_field :abbr, 'Company name abbreviature(same as on stock markets)'
        response_field :exchange, 'Company stock exchange'
        response_field :target_url, 'Company page URL'
        response_field :followers_count, 'Amount of followers'

        let(:user_id) { user.id }

        example_request "Retrieving a list of companies that user follows" do
          company_expectations.call(json.first)
          expect( json.length ).to be_eql(1)
        end
      end
    end
  end
end
