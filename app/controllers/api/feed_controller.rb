class Api::FeedController < ApplicationController
  before_action :authenticate_user!

  def index
    @feed = Feed.new(nil, 'command', current_user, page: params[:page], target_user: current_user, latest_post_id: params[:latest_post_id])
    render 'api/shared/feeds/_base'
  end
end
