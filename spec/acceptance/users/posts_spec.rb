require 'acceptance_helper'

resource 'UserPosts', type: :acceptance do
  header 'Accept', 'application/json'
  header 'Content-Type', 'application/json'

  context 'signed in' do
    let(:user) { create(:user) }

    before do
      no_doc do
        create(:post, user: user)
        client.post '/login.json', user: { email: user.email, password: user.password }
      end
    end

    get '/api/users/:user_id/posts' do
      parameter :user_id, 'User ID', required: true

      let(:user_id) { user.id }

      it_behaves_like 'feed', "Retrieves all visible posts from user feed"
    end
  end
end
