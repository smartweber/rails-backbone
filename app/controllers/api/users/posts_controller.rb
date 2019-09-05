class Api::Users::PostsController < ApplicationController

  def index
    @feed = Feed.new(params[:user_id], 'user', current_user, page: params[:page])
    render 'api/shared/feeds/_base'
  end
end
