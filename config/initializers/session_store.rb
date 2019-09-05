# Be sure to restart your server when you modify this file.

Rails.application.config.session_store :redis_store,
  key: '_stockharp_app_session',
  expires_in: 7.days,
  servers: {
    host: APP_CONFIG[:redis][:host],
    port: APP_CONFIG[:redis][:port],
    db: APP_CONFIG[:redis][:sessions_db],
    password: APP_CONFIG[:redis][:password],
    namespace: APP_CONFIG[:redis][:namespace]
  }
