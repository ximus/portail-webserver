module Rack
  class DisableHTTPCaching < Struct.new(:app)
    def call(env)
      response = app.call(env)
      response[1]['Cache-Control'] = 'no-cache, no-store, max-age=0, must-revalidate'
      response[1]['Expires']       = 'Fri, 01 Jan 2010 00:00:00 GMT'
      response
    end
  end
end