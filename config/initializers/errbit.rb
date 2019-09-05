Airbrake.configure do |config|
  config.api_key = 'c1e28b4829e168700ac496b60455e100'
  config.host    = '54.200.202.193'
  config.port    = 80
  config.secure  = config.port == 443
  config.development_environments = %w(development test)
end
