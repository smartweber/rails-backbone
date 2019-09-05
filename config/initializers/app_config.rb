APP_CONFIG = YAML.load(ERB.new(File.read(Rails.root+'config/app_config.yml')).result).with_indifferent_access[Rails.env]

module StockharpApp
  class Application < Rails::Application
    config.redis         = ActiveSupport::OrderedOptions.new
    config.redis.faye    = ActiveSupport::OrderedOptions.new
    redis_password       = APP_CONFIG[:redis][:password] ? ":#{APP_CONFIG[:redis][:password]}@" : ''
    redis_url_without_db = "redis://#{redis_password}#{APP_CONFIG[:redis][:host]}:#{APP_CONFIG[:redis][:port]}/"
    config.redis.main_url       = redis_url_without_db + APP_CONFIG[:redis][:main_db]
    config.redis.sessions_url   = redis_url_without_db + APP_CONFIG[:redis][:sessions_db]
    config.redis.faye.namespace = "faye_redis:"
  end
end
