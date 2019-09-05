class Api::FavoritesController < ApplicationController
  before_action :authenticate_user!, except: :index
  after_action :verify_authorized, except: :index
  after_action :verify_policy_scoped, only: :index

  def create
    @post = Post.find(params[:post_id])
    authorize @post, :favorite?
    @favorite = current_user.favorite(@post)
    if @favorite.persisted?
      render 'create', status: 201
    else
      render(json: {errors: @favorite.errors.messages}, status: 400)
    end
  end

  def destroy
    @post = current_user.favorited_posts.find(params[:id])
    authorize @post, :unfavorite?
    current_user.unfavorite(@post)
    render json: {}, status: 204
  end

  def index
    favorited_posts = policy_scope(Favorite)
    @posts = favorited_posts.order('created_at DESC').page(params[:page])
  end
end
