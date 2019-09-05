class Api::RecommendationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user
  before_action :set_limit

  def companies
    recommender = CompanyRecommender.new(@user)
    @companies = recommender.recommendations.take(@limit.to_i)
    respond_to do |format|
      format.json { render 'api/companies/simplified_index' }
    end
  end

  private
    def set_user
      @user = User.find(params[:id])
    end

    def set_limit
      @limit = params[:limit] || 3
    end
end
