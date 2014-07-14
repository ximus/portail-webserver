require 'rack/session/cookie'
require 'rack-server-pages'
require 'omniauth'

App.define_routes do
  if App.env.development?
    use Rack::DisableHTTPCaching
    # use Rack::CodeReloader
  end

  class LoggingMiddleware < Struct.new(:app)
    def call(env)
      env['rack.error'] = env['rack.logger'] = App.log
      app.call(env)
    end
  end
  use LoggingMiddleware

  # avoid ActiveRecord::ConnectionTimeoutError
  use ActiveRecord::ConnectionAdapters::ConnectionManagement

  use Rack::Session::Cookie, {
    expire_after: 2592000, # 30 days
    secret: (App.config.session_secret || raise('need a session secret'))
  }

  App.assets.basepath = '/assets'
  map App.assets.basepath do
    run App.assets
  end

  use Rack::StaticIfPresent, urls: ["/"], root: App.root.join('static')

  # Routes: /auth/:provider, /auth/:provider/callback
  use OmniAuth::Builder do
    # Dynamically load providers from app config
    Auth.providers.each do |(_, provider)|
      omniauth_id = provider[:omniauth][:id]
      args = provider[:omniauth][:args] || []
      provider(omniauth_id, *args, {
        # TODO: this needs to go
        # https://github.com/intridea/omniauth-oauth2/issues/58
        provider_ignores_state: true
      })
    end
  end

  map '/auth' do
    run AuthController
  end

  # map '/views' do
  #   run Views.new
  # end

  run MainController
end