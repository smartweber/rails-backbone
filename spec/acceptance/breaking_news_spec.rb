require 'acceptance_helper'

resource 'BreakingNews', type: :acceptance do
  header 'Accept', 'application/json'
  header 'Content-Type', 'application/json'

  context 'signed in' do
    let(:user) { create(:user) }
    let(:excluded_attributes) { %w(created_at trending_until) }

    before do
      no_doc do
        client.post '/login.json', user: { email: user.email, password: user.password }
      end
    end

    get '/api/breaking_news' do
      response_field :id, 'Breaking News ID'
      response_field :title, 'Breaking News title'
      response_field :updated_at, 'Breaking News last update time'

      let!(:breaking_news) { create(:breaking_news) }

      example_request "Getting the latest Breaking News" do
        expect(status).to eq(200)
        expect( json ).to be_eql( convert_times(breaking_news.reload.attributes).except!(*excluded_attributes) )
      end
    end
  end
end
