if defined?(Treat)
  Treat.databases.mongo.db   = "omega_#{Rails.env}"
  Treat.databases.mongo.host = 'localhost'
  Treat.databases.mongo.port = '27017'
end
