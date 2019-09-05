# Make sure that jobs don't drag around
RSpec.configure do |config|
  config.before(:each) do
    Sidekiq::Worker.clear_all
  end
end
