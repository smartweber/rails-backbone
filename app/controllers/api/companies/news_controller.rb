class Api::Companies::NewsController < ApplicationController

  def index
    company = Company.find_by_abbr!(params[:company_id])
    @news   = company.latest_news(params[:page])
  end
end
