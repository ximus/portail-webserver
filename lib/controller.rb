require 'sinatra'

class Controller < Sinatra::Application
  helpers ControllerHelpers
  helpers ViewHelpers
  use Rack::CommonLogger

  enable :sessions
  enable :logging

  # TODO: setup proper initialization
  Tilt.register Tilt::ERBTemplate, 'html.erb'

  set :views, App.root.join('app/views')

  before do
    if App.env.development?
      App.log.info("rack.session: #{env['rack.session'].inspect}")
    end
  end
end