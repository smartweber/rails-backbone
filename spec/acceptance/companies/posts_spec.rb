require 'acceptance_helper'

resource 'CompanyPosts', type: :acceptance do
  header 'Accept', 'application/json'
  header 'Content-Type', 'application/json'

  context 'signed in' do
    let(:user) { create(:user) }
    let!(:company) { create(:company) }

    before do
      no_doc do
        create(:post, content: "$#{company.abbr} mentioned")
        client.post '/login.json', user: { email: user.email, password: user.password }
      end
    end

    get '/api/c/:company_id/posts' do
      let(:company_id) { company.abbr }

      it_behaves_like "feed", "Retrieve posts that mention company name"
    end
  end
end
