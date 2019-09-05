class Api::MarketHeadlinesController < ApplicationController

  def index
    @market_headlines = MarketHeadline.order('position ASC').limit(10)
    render 'api/market_headlines/index'
  end
end
