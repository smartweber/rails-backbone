class Api::Users::SessionsController < Devise::SessionsController
# before_filter :configure_sign_in_params, only: [:create]
  respond_to :json, :html

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  def create
    super do |resource|
      if user_signed_in?
        load_notifications
        set_csrf_token_header
      end
    end
  end

  # DELETE /resource/sign_out
  def destroy
    super do |resource|
      set_csrf_token_header unless user_signed_in?
    end
  end

  protected

    def load_notifications
      @notifications = []
      %w(message common stock).each do |type|
        el = OpenStruct.new( { arr: resource.notifications.unseen.send("with_#{type}_type").page(1), type: type })
        @notifications << el
      end
    end

    def set_csrf_token_header
      response.headers['X-CSRF-Token'] = form_authenticity_token
    end

  # You can put the params you want to permit in the empty array.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.for(:sign_in) << :attribute
  # end
end
