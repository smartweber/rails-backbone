class Api::MessagesController < ApplicationController
  before_action :authenticate_user!
  after_action  :verify_authorized, only: :create
  after_action  :verify_policy_scoped, only: :index

  # TODO: refactor
  def create
    user = User.find_by_username(params[:message][:username])
    if user
      chat = Chat.find_or_build(current_user, user)
      Message.transaction do
        chat.save if chat.new_record?
        chat.add_participants( current_user, user )
        participant = chat.participants.find_by_user_id(current_user.id)
        @message    = Message.new(message_params.merge(participant_id: participant.id, chat_id: chat.id))
        authorize @message
      end
      if @message.save
        @message.subscribe_target_participant
        render 'create', status: 201
      else
        render 'create', status: 400
      end
    else
      skip_authorization
      render nothing: true, status: 400
    end
  end

  def index
    chats     = policy_scope(Chat)
    chat      = chats.where(id: params[:chat_id]).first
    raise ActiveRecord::RecordNotFound unless chat
    @messages = chat.messages.includes(:attachments, :participant => [:user]).order('created_at DESC').page(params[:page]).reverse
  end

  private

    def message_params
      params.require(:message).permit(:body, {attachments: []}, {attachment_ids: []})
    end

end
