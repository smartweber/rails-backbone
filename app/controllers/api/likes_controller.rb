class Api::LikesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_like, only: [:destroy]
  after_action  :verify_authorized

  # POST /likes
  def create
    @like = Like.new(permitted_attributes(Like.new).merge(user_id: current_user.id))
    authorize @like

    if @like.save
      render 'create', status: 201
    else
      render(json: {errors: @like.errors.messages}, status: 400)
    end
  end

  # DELETE /likes/1
  def destroy
    authorize @like
    @like.destroy
    render json: {}, status: 204
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_like
      @like = Like.find(params[:id])
    end
end
