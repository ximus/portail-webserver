require 'rack/session/cookie'
require 'rack/disable_lint'
require 'rack-server-pages'
require 'omniauth'

App.define_routes do
  # warmup do |app|
  #   client = Rack::MockRequest.new(app)
  #   client.get('/')
  # end

  if App.env.development?
    use Rack::DisableHTTPCaching
    # use Rack::CodeReloader
  end

  ###############################
  #
  # Logging middleware
  #
  ###############################

  class LoggingMiddleware < Struct.new(:app)
    def call(env)
      env['rack.error'] = env['rack.logger'] = App.log
      app.call(env)
    end
  end
  use LoggingMiddleware


  ###############################
  #
  # DB middleware
  #
  ###############################

  # avoid ActiveRecord::ConnectionTimeoutError
  use ActiveRecord::ConnectionAdapters::ConnectionManagement


  ###############################
  #
  # Session middleware
  #
  ###############################

  use Rack::Session::Cookie, {
    expire_after: 2592000, # 30 days
    secret: (
      App.config.session_secret || raise('missing session secret')
    )
  }


  ###############################
  #
  # Websockets middleware
  #
  ###############################

  map '/gate/ws' do
    run Gate::Websocket.new
  end

  ###############################
  #
  # Assets middleware
  #
  ###############################

  App.assets.basepath = '/assets'
  map App.assets.basepath do
    run App.assets
  end


  ###############################
  #
  # Static files middleware
  #
  ###############################

  # Register web client path
  use Rack::StaticIfPresent, urls: ["/"], root: App.paths.client
  App.log.info "Registered client path at #{App.paths.client}"
  # Register static dirs
  use Rack::StaticIfPresent, urls: ["/"], root: App.paths.public


  ###############################
  #
  # Auth middleware
  #
  ###############################

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


  # map '/views' do
  #   run Views.new
  # end

  ###############################
  #
  # Controllers
  #
  ###############################

  run Rack::Cascade.new([
    MainController,
    AuthController,
    GateController
  ])
end
