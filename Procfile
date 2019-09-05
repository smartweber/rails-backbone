sidekiq: bundle exec sidekiq -q default -q mailers
faye: bundle exec thin start -R lib/faye_server/config.ru -p 9292
web: rails s puma
