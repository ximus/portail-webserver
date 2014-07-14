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

Dir[App.root.join("spec/factories/**/*.rb")].each { |f| require f }
Dir[App.root.join("spec/support/**/*.rb")].each   { |f| require f }

# DatabaseCleaner.strategy = :transaction
DatabaseCleaner.strategy = :truncation

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
  config.include OmniauthMacros
  config.include FeatureMacros

  config.mock_with :rspec
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before(:all) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    OmniAuth.config.mock_auth[:default] = mock_omniauth_hash
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning { example.run }
  end
end

# maybe this should only be true for login tests
OmniAuth.config.test_mode = true