class Api::ArticlesController < ApplicationController

  def index
    @articles = Article.where.not(position: nil).order('position ASC').limit(8)
    render 'api/articles/index'
  end

  def show
    @article = Article.friendly.find(params[:id])
    render 'api/articles/show'
  end

  def feed
    @feed = Feed.new(params[:id], 'article', current_user, page: params[:page], latest_post_id: params[:latest_post_id])
    render 'api/shared/feeds/_base'
  end
end
