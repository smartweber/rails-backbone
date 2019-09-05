module Bayeux
  def self.client
    @client ||= begin
      Thread.new { EM.run } unless EM.reactor_running?
      Thread.pass until EM.reactor_running?
      protocol = Rails.env.production? ? 'https' : 'http'
      client = Faye::Client.new("#{protocol}://#{APP_CONFIG[:faye][:host]}:#{APP_CONFIG[:faye][:port]}/faye")
      client.add_extension(ServerAuthInjector.new)
      client
    end
  end

  class ServerAuthInjector
    def outgoing( message, callback )
      server_auth_password = '58c1319eb573a495fef29ecf22c8cf9ce4204b6e47108ee0f4664ef4ec8b3a8a3c98fdcb2c241b4fb8dd74771b0e82907a96291d9d40ec484138c943e48da2b3'
      message['ext'] ||= {}
      message['ext']['server_auth_password'] = server_auth_password
      callback.call(message)
    end
  end
end
