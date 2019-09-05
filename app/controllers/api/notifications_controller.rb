class Api::NotificationsController < ApplicationController
  before_action :authenticate_user!, except: :index
  before_action :basic_authentication, only: [:index]
  after_action  :verify_authorized, only: :update
  # after_action  :verify_policy_scoped, only: :index

  def update
    @notification = current_user.notifications.where(id: params[:id]).first
    authorize @notification
    if @notification.update_attributes(notification_params)
      render 'show'
    else
      render(json: {errors: @notification.errors.messages}, status: 400)
    end
  end

  def index
    user_notifications = NotificationPolicy::Scope.new(@user, Notification).resolve
    @notifications     = user_notifications.unseen
  end

  private

    def basic_authentication
      unless @user = authenticate_with_http_basic { |email, password| User.authenticate(email, password) }
        request_http_basic_authentication
      end
    end

    def notification_params
      params.require(:notification).permit(:seen)
    end
end
