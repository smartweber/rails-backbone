class RailsEnvConfigMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    env.merge!(Rails.application.env_config)
    @app.call(env)
  end
end
