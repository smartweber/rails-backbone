module LiveRefresh
  def self.extract_abbr_from(channel)
    /c\/([a-zA-Z]+)\z/.match(channel)[1]
  end

  def self.start
    @client ||= begin
      Thread.new do
        EM.error_handler do |e|
          Airbrake.notify(e)
        end
        EM.run{
          EM.defer { LiveRefresh::Service.new }
        }
      end unless EM.reactor_running?
      Thread.pass until EM.reactor_running?
    end
  end
end
