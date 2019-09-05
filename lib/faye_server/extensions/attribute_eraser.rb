class AttributeEraser
  def outgoing( message, callback )
    message['ext'].delete('server_auth_password') if message['ext']
    callback.call(message)
  end
end
