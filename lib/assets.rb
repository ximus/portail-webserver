require 'sass'
require 'compass'
require 'uglifier'
require 'sprockets'
require 'sprockets-sass'
require 'bootstrap-sass'

compass_config = Compass.detect_configuration_file(App.root)
Compass.add_project_configuration(compass_config)

Sass.load_paths << App.root.join('app/assets/vendor')

# this circumvents an error
module Bootstrap
  class << self
    def asset_pipeline?
      false
    end
  end
end

# this circumvents an error
Sprockets::Sass.add_sass_functions = false

class Assets < Sprockets::Environment
  attr_accessor :basepath

  def initialize
    super
    append_path('app/assets')
    append_path(Bootstrap.javascripts_path)

    if App.env.production?
      self.js_compressor  = :uglify
      self.css_compressor = :scss
    end
  end
end