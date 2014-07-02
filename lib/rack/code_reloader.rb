require 'active_support/file_update_checker'
require 'active_support/descendants_tracker'
require 'active_support/dependencies'

module Rack
  class CodeReloader
    def initialize(app)
      @app = app
      paths = {}
      ActiveSupport::Dependencies.autoload_paths.each do |path|
        paths[path.to_s] = [:rb]
      end

      @reloader = ActiveSupport::FileUpdateChecker.new([], paths, &method(:reload!))
    end

    def call(env)
      @reloader.execute
      @app.call(env)
    end

    def reload!
      puts "reload!"
      ActiveSupport::DescendantsTracker.clear
      ActiveSupport::Dependencies.clear
    end
  end
end