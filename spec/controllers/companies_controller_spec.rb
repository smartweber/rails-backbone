require 'rails_helper'

RSpec.describe Api::CompaniesController, :type => :controller, vcr: { cassette_name: 'company_page' } do
  before do
    @abbr = "APPL"
    @correct_result = create(:company, abbr: @abbr)
    create(:company, abbr: "APOL")
  end

  describe "GET index" do
    it "returns http success" do
      get :index, query: "APP", format: :json
      expect(response).to have_http_status(:success)
    end

    it "find proper records" do
      get :index, query: "APP", format: :json
      expect(assigns(:companies).results).to be_eql([@correct_result])
    end
  end

  describe "GET show" do
    before { sign_in create(:user) }

    it "returns http success" do
      get :show, id: @abbr, format: :json
      expect(response).to have_http_status(:success)
    end

    it "finds proper record" do
      get :show, id: @abbr, format: :json
      expect(assigns(:company)).to be_eql(@correct_result)
    end
  end

end
