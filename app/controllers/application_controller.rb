# TODO: remove and replace gon.rabl using FakeScope to make helpers available for rabl views
include UsersHelper

class ApplicationController < ActionController::Base
  include Pundit
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  before_action :authenticate
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :preload_gon_data, if: 'request.format.html?'

  protected

    def configure_permitted_parameters
      devise_parameter_sanitizer.for(:sign_up) << [:name, :username, :tos_and_pp_accepted]
      devise_parameter_sanitizer.for(:account_update) << [:name, :notification_subscription]
    end

    def preload_gon_data
      @user            = current_user
      @notifications   = []
      gon.current_user = {}
      unless @user.nil?
        %w(message common stock).each do |type|
          el = OpenStruct.new({ arr: @user.notifications.includes(:notifiable).unseen.send("with_#{type}_type").page(1),
                                type: type })
          @notifications << el
        end
      end
      gon.rabl template: "app/views/api/users/show.json.rabl", as: "current_user"
    end

    def user_not_authorized
      render json: {}, status: 401
    end

    def not_found
      respond_to do |f|
        f.json { render json: {}, status: 404 }
        f.html { render file: 'public/404', status: 404 }
      end
    end

    def authenticate
      if Rails.env.staging?
        authenticate_or_request_with_http_basic do |username, password|
          username == "guest" && password == "stockharp#09"
        end
      end
    end
end
