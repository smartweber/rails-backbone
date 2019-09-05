class Api::Users::PasswordsController < Devise::PasswordsController
  respond_to :json, :html

  def update
    super do |resource|
      load_notifications
      set_csrf_token_header
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

end
