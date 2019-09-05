RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods

  FactoryGirl.define do
    after(:create) {|obj| obj.class.reindex if obj.class.respond_to?(:reindex) }
  end

  # Running with LINT variable set would test factories for valid?
  if ENV["LINT"]
    config.before(:suite) do
      begin
        DatabaseCleaner.start
        FactoryGirl.lint
      ensure
        DatabaseCleaner.clean
      end
    end
  end
end
