class Api::Following::CompaniesController < ApplicationController
  before_action :authenticate_user!
  after_action :verify_policy_scoped

  def index
    @following_companies = policy_scope(Relationship).includes(:followable).where(follower_id: params[:user_id], followable_type: 'Company').map(&:followable)
    QuoteMedia.client.get_quote(@following_companies.map(&:abbr))
  end
end
