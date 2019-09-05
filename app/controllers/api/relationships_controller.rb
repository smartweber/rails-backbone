class Api::RelationshipsController < ApplicationController
  before_action :authenticate_user!
  # TODO: add pundit authorization

  def create
    @followable   = params[:followable_type].titleize.constantize.where(id: params[:followable_id]).first
    @relationship = current_user.follow(@followable)
    if @relationship.persisted?
      render 'create', status: 201
    else
      render(json: {errors: @relationship.errors.messages}, status: 400)
    end
  end

  def destroy
    @followable = Relationship.find(params[:id]).followable
    current_user.unfollow(@followable)
    render json: {}, status: 204
  end
end
