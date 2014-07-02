require 'rack/session/cookie'
require 'rack-server-pages'
require 'omniauth'

app = App.instance

app.define_routes do
  if app.env.development?
    use Rack::DisableHTTPCaching
    # use Rack::CodeReloader
  end

  class LoggingMiddleware < Struct.new(:app)
    def call(env)
      env['rack.error'] = env['rack.logger'] = App.instance.log
      app.call(env)
    end
  end
  use LoggingMiddleware

  # avoid ActiveRecord::ConnectionTimeoutError
  use ActiveRecord::ConnectionAdapters::ConnectionManagement

  use Rack::Session::Cookie, {
    expire_after: 2592000, # 30 days
    secret: (app.config.session_secret || raise('need a session secret'))
  }

  app.assets.basepath = '/assets'
  map app.assets.basepath do
    run app.assets
  end

  # Routes: /auth/:provider, /auth/:provider/callback
  use OmniAuth::Builder do
    # Dynamically load providers from app config
    app.config.auth.providers.each do |(provider_id, args)|
      provider(provider_id, *args, {
        # TODO: this needs to go
        # https://github.com/intridea/omniauth-oauth2/issues/58
        provider_ignores_state: true
      })
    end
  end

  map '/auth' do
    run AuthController
  end

  map '/views' do
    run Views.new
  end

  run MainController
end