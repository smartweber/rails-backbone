require 'rack'
require 'rack/session/redis'
require 'faye'
require 'faye/websocket'
require 'faye/redis'
require 'rabl'
require ::File.expand_path('../../../config/environment',  __FILE__)
require_relative 'rails_env_config_middleware'
require_relative 'extensions/csrf_protection'
require_relative 'extensions/message_saver'
require_relative 'extensions/attribute_eraser'

Faye::WebSocket.load_adapter('thin')

use RailsEnvConfigMiddleware

use Rack::Session::Redis,
  expires_in: 30.minutes,
  key: '_stockharp_app_session',
  redis_server: Rails.configuration.redis.sessions_url

extensions = [CsrfProtection.new, MessageSaver.new, AttributeEraser.new]
bayeux     = Faye::RackAdapter.new(
                                    extensions: extensions, mount: '/faye', timeout: 25,
                                    engine: {type: Faye::Redis, uri: Rails.configuration.redis.main_url, namespace: Rails.configuration.redis.faye.namespace, database: 0}
                                  )

ActiveRecord::Base.connection

run bayeux
