class Api::CompaniesController < ApplicationController
  # TODO: authenticate && authorize here

  def index
    @companies = Company.autocomplete_by_abbr(params[:query])

    respond_to do |format|
      format.json { render 'api/companies/simplified_index' }
    end
  end

  def show
    @company = Company.find_by_abbr!(params[:id])
    QuoteMedia.client.get_quote(@company.abbr)

    if @company and current_user
      @relationship = @company.passive_relationships.find_by_follower_id(current_user.id)
    end

    respond_to do |f|
      f.html
      f.json { render 'show', status: (@company ? 200 : 404) }
    end
  end

  def trending
    @companies = Company.asc_by_position.limit(5)
    QuoteMedia.client.get_quote(@companies.map(&:abbr))

    # TODO: separate view with custom set of returned data
    respond_to do |format|
      format.json { render 'api/companies/index' }
    end
  end

  def market_snapshot
    @companies = Company.market_snapshot
    QuoteMedia.client.get_quote(@companies.map(&:abbr))

    # TODO: separate view with custom set of returned data
    respond_to do |format|
      format.json { render 'api/companies/index' }
    end
  end
end
