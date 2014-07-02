class Views < Rack::ServerPages

  def initialize(app = nil, options = {})
    super(app, options) do |config|
      config[:view_path] = 'app/views'
      config.helpers ViewHelpers
    end
  end
end
