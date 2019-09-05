class Api::UserAttachmentsController < ApplicationController
  before_action :authenticate_user!
  after_action  :verify_authorized

  def create
    @attachment = UserAttachment.new(link: params[:link], user_id: current_user.id)
    authorize @attachment
    if @attachment.save
      render 'create'
    else
      render(json: {errors: @attachment.errors.messages}, status: 400)
    end
  end

  def destroy
    @attachment = UserAttachment.find(params[:id])
    authorize @attachment
    @attachment.destroy
    render json: {}, status: 204
  end
end
