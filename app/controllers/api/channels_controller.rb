class Api::ChannelsController < ApplicationController

  def show
    @feed = Feed.new(params[:id], 'channel', current_user, page: params[:page], latest_post_id: params[:latest_post_id])
    raise ActiveRecord::RecordNotFound if @feed.posts.empty?
    render 'api/shared/feeds/_base'
  end

  def index
    @tags = Tag.hashtags_by_position.limit(params[:limit])
  end
end
