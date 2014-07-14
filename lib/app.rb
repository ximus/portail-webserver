require 'active_support/core_ext/hash/indifferent_access.rb'
require 'active_support/core_ext/hash/deep_merge.rb'
require 'active_support/core_ext/hash/slice.rb'
require 'active_support/core_ext/hash/keys.rb'
require 'active_support/core_ext/module/delegation.rb'
require 'active_support/core_ext/class/attribute.rb'
require 'active_support/core_ext/string'
require 'active_support/dependencies'
require 'fileutils'
require 'pathname'

require 'settingslogic'

require 'active_record'
require 'activeuuid'

# MultiJson.load_options = { symbolize_keys: true }

module App
  extend self

  DEFAULT_PATHS = {
    migrations: 'db/migrate',
    tests:      'spec',
    log:        'log',
    tmp:        'tmp'
  }

  attr_reader :env
  attr_reader :log
  alias_method :logger, :log
  attr_reader :root
  attr_reader :config
  attr_reader :i18n
  attr_reader :db
  attr_reader :endpoint
  attr_reader :assets
  attr_reader :paths

  def request_thread_count
    if const_defined?('Puma') and Puma.respond_to?(:cli_config)
      Puma.cli_config.options[:max_threads]
    else
      2
    end
  end

  def init
    root_path = File.expand_path('..', File.dirname(__FILE__))
    @root   = Pathname.new(root_path)
    @paths  = OpenStruct.new(DEFAULT_PATHS.inject({}) { |h, (k, v)| h[k] = root.join(v); h })
    @env    = (ENV['ENV'] || ENV['RACK_ENV'] || 'development').inquiry
    FileUtils.mkdir_p(root.join('log'))
    @log    = Logger.new(paths.log.join("#{env}.log"))
    # DESIGN: I wish Auth module took care of this initialization
    OmniAuth.config.logger = log
    @config = load_config
    @i18n   = config.i18n
    # wrap all paths with a Pathname off root
    initialize_autoload_paths
    initialize_persistance
    @assets = Assets.new
    load_routes
  end

  def load_routes
    require root.join('config/routes')
  end

  def initialize_autoload_paths
    ActiveSupport::Dependencies.autoload_paths += [
      root.join("lib"),
      root.join("app/models"),
      root.join("app/helpers"),
      root.join("app/controllers")
    ]
  end

  def call(env)
    endpoint.call(env)
  end

  def initialize_persistance
    config = self.config.database
    config[:pool] = App.request_thread_count
    log.info("ActiveRecord connection pool size: #{config[:pool]}")
    ActiveRecord::Base.logger = log
    ActiveRecord::Base.establish_connection(config)
    # Bundler requires activeuuid too early, patches need to be reapplied
    ActiveUUID::Patches.apply!
  end

  # paths config/application.yml and config/application/environment/{appenv}.yml
  # will be searched for optional config files. Env-specific config will
  # override application.yml
  def load_config
    config_path = root.join('config')
    config = {}
    # %W(application.yml environment/development.yml).each do |path|
    %W(application.yml environment/#{env}.yml).each do |path|
      path = config_path.join(path)
      if File.exists?(path)
        contents = YAML::load(IO.read(path))
        config.deep_merge!(contents) if contents
      end
    end
    Settingslogic.new(HashWithIndifferentAccess.new(config))
  end

  def define_routes(&block)
    @endpoint ||= Rack::Builder.new(&block)
  end
end