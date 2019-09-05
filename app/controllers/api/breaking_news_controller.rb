class Api::BreakingNewsController < ApplicationController

  def show
    @breaking_news = BreakingNews.enabled.first
  end
end
