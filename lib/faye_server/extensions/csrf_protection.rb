class CsrfProtection
  extend ActionController::RequestForgeryProtection

  def incoming(message, request, callback)
    # TODO: move that to Rails conf variable
    server_auth_password = '58c1319eb573a495fef29ecf22c8cf9ce4204b6e47108ee0f4664ef4ec8b3a8a3c98fdcb2c241b4fb8dd74771b0e82907a96291d9d40ec484138c943e48da2b3'
    session_token        = request.session['_csrf_token']
    message_token        = message['ext'] && message['ext'].delete('csrfToken')
    server_side_message  = message['ext'] && message['ext']['server_auth_password'] == server_auth_password
    unless server_side_message
      unless self.class.send(:valid_authenticity_token?, request.session, message_token)
        message['error'] = '401::Access denied:Csrf'
      else
        message["data"]["user_id"] = request.session['warden.user.user.key'][0][0] unless message["channel"] =~ /meta/
      end
    end
    callback.call(message)
  end
end
