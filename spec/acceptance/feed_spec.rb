require 'acceptance_helper'

resource 'Feed', type: :acceptance do
  header 'Accept', 'application/json'
  header 'Content-Type', 'application/json'

  context 'signed in' do
    let!(:user) { u = create(:user); create_list(:post, 2, user: u); u }

    before do
      no_doc do
        client.post '/login.json', user: { email: user.email, password: user.password }
      end
    end

    get '/api/feed' do
      it_behaves_like "feed", 'Retrieve user-specific feed'
    end
  end
end
