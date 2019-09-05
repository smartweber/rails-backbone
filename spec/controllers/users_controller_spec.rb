require 'rails_helper'

RSpec.describe Api::UsersController, type: :controller do

  describe "autocomplete" do
    before do
      create(:user, name: 'Jack Jackson')
      create(:user, name: 'Jackson Jack')
    end
    before { sign_in User.last }

    it "populates variables with distint results" do
      get :index, query: 'jack', format: :json
      expect(assigns(:users).results.size).to be 2
    end
  end
end
