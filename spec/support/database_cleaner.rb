require 'database_cleaner'

RSpec.configure do |config|
  # TODO: set it to config variable
  redis_url = Rails.configuration.redis.main_url
  DatabaseCleaner[:redis, { connection: redis_url }].strategy = :truncation

  config.before(:suite) do
    DatabaseCleaner[:active_record].clean_with(:truncation)
    DatabaseCleaner[:redis].clean_with(:truncation)
  end

  config.before(:each) do |example|
    DatabaseCleaner[:active_record].strategy = :transaction
  end

  config.before(:each, :js => true) do
    DatabaseCleaner[:active_record].strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end
