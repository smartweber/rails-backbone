class Api::Companies::PostsController < ApplicationController

  def index
    @feed = Feed.new(params[:company_id], 'company', current_user, page: params[:page], latest_post_id: params[:latest_post_id])
    render 'api/shared/feeds/_base'
  end
end
