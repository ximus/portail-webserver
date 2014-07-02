ENV['ENV'] ||= 'test'

require 'rspec'
require 'factory_girl'
require 'capybara'
require 'capybara/rspec'
require 'capybara/poltergeist'
require 'capybara-screenshot'
require 'capybara-screenshot/rspec'
require 'database_cleaner'

require_relative '../config/boot'

Dir[App.instance.root.join("spec/factories/**/*.rb")].each { |f| require f }
Dir[App.instance.root.join("spec/support/**/*.rb")].each   { |f| require f }

DatabaseCleaner.strategy = :transaction

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
  config.include OmniauthMacros

  config.mock_with :rspec
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before(:each) do
    mock_auth_hash
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning { example }
  end
end

# maybe this should only be true for login tests
OmniAuth.config.test_mode = true