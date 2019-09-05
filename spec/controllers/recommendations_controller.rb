require 'rails_helper'

RSpec.describe Api::RecommendationsController, type: :controller do

  describe "GET #companies" do
    let(:user1) { create(:user) }
    let(:user2) { create(:user) }

    before do
      2.times { create(:company) }
      sign_in user2
    end

    it "populates company recommendations" do
      get :companies, id: user1.id, format: :json
      expect(assigns(:companies).count).to eq 2
    end

  end

end
