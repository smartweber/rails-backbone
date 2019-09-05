class Api::NewsArticlesController < ApplicationController
  before_action :authenticate_user!, except: [:ranged, :show, :feed]
  after_action :verify_policy_scoped, only: :index

  def index
    news_articles_array = policy_scope(GeneralNewsItem)
    @news_articles = Kaminari.paginate_array(news_articles_array).page(params[:page]).per(4)

    respond_to do |f|
      f.json
    end
  end

  def ranged
    @news_articles = GeneralNewsItem.with_positions_between(params[:lowBorder].to_i, params[:highBorder].to_i)

    respond_to do |f|
      f.json{ render 'api/news_articles/index' }
    end
  end

  def show
    @news_article = GeneralNewsItem.friendly.find(params[:id])

    respond_to do |f|
      f.json{ render 'api/news_articles/show' }
    end
  end

  def feed
    @feed = Feed.new(params[:id], 'news_article', current_user, page: params[:page], latest_post_id: params[:latest_post_id])
    render 'api/shared/feeds/_base'
  end
end
