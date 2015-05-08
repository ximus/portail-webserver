require 'sinatra'

class Controller < Sinatra::Application
  helpers ControllerHelpers
  helpers ViewHelpers

  # set :raise_errors, true
  # set :show_exceptions, true

  # enable :logging

  # TODO: setup proper initialization
  Tilt.register Tilt::ERBTemplate, 'html.erb'

  set :views, App.root.join('app/views')

  before do
    if App.env.development?
      # a simple read access to force loading the session
      session['foo'] = 'foobar'
      log.debug("rack.session: #{session.inspect}")
    end
  end
end
