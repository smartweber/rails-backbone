class Api::ParticipantsController < ApplicationController
  before_action :authenticate_user!
  after_action  :verify_authorized

  def update
    @participant = Participant.find(params[:id])
    authorize @participant
    if @participant.update_attributes(participant_params)
      render 'show'
    else
      render(json: {errors: @participant.errors.messages}, status: 400)
    end
  end

  private

  def participant_params
    params.require(:participant).permit(:last_seen_message_id)
  end
end
