class Api::PostsController < ApplicationController
  before_action :authenticate_user!, except: [:trending]
  before_action :set_post, only: [:destroy]
  after_action  :verify_authorized, except: [:trending]

  def create
    @post = current_user.posts.build(permitted_attributes(Post.new))
    authorize @post

    if @post.save
      render 'create', status: 201
    else
      render(json: {errors: @post.errors.messages}, status: 400)
    end
  end

  def destroy
    authorize @post
    @post.mark_for_destroy
    render json: {}, status: 204
  end

  def trending
    @feed = Feed.new(nil, 'trending', current_user)
    respond_to do |format|
      format.json { render 'api/companies/feeds/_base' }
    end
  end

  private

    def set_post
      @post = current_user.posts.find_by!(id: params[:id])
    end
end
