require 'sinatra'

class Controller < Sinatra::Application
  helpers ControllerHelpers
  helpers ViewHelpers
  use Rack::CommonLogger

  enable :sessions
  enable :logging

  # TODO: setup proper initialization
  Tilt.register Tilt::ERBTemplate, 'html.erb'

  set :views, App.instance.root.join('app/views')
end