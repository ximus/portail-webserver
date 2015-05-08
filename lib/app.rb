require 'active_support/core_ext/hash/indifferent_access.rb'
require 'active_support/core_ext/hash/deep_merge.rb'
require 'active_support/core_ext/hash/slice.rb'
require 'active_support/core_ext/hash/keys.rb'
require 'active_support/core_ext/module/delegation.rb'
require 'active_support/core_ext/class/attribute.rb'
require 'active_support/core_ext/string'
require 'active_support/core_ext/module'
require 'active_support/core_ext/object'
require 'active_support/dependencies'
require 'fileutils'
require 'pathname'

require 'settingslogic'

require 'active_record'
require 'activeuuid'

require 'multi_delegator'
MultiJson.load_options = { symbolize_keys: true }

module App
  extend self

  DEFAULT_PATHS = {
    migrations: 'db/migrate',
    tests:      'spec',
    log:        'log',
    tmp:        'tmp',
    config:     'config',
    public:     'static'
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


  def init
    @env = (
      ENV['ENV'] || ENV['RACK_ENV'] || 'development'
    ).inquiry
    initialize_root_path
    initialize_config
    initialize_paths
    initialize_autoload_paths
    initialize_logging
    @i18n = config.i18n
    initialize_persistance
    @assets = Assets.new
    load_routes
    run_env_initializers
  end

  def initialize_autoload_paths
    ActiveSupport::Dependencies.autoload_paths += [
      root.join("lib"),
      root.join("app/models"),
      root.join("app/helpers"),
      root.join("app/controllers")
    ]
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

  def initialize_root_path
    root_path = File.expand_path('..', File.dirname(__FILE__))
    @root = Pathname.new(root_path)
  end

  def initialize_paths
    # wrap all paths with a Pathname off root
    paths_hash = DEFAULT_PATHS.inject({}) do |h, (k, v)|
      h[k] = Array.wrap(v).compact.map do |path|
        root.join(path)
      end
      h[k] = h[k].first if h[k].count == 1
      h
    end
    # import custom path overrides
    if config.paths
      config.paths.each do |k,v|
        paths_hash[k] = Pathname.new(v)
      end
    end
    @paths = OpenStruct.new(paths_hash)
  end

  def initialize_logging
    FileUtils.mkdir_p(paths.log)
    log_file = File.open(paths.log.join("#{env}.log"), "a")
    # log both to file and stdout in developement
    if env.development?
      STDOUT.sync = true
      log_io = MultiDelegator.delegate(:write, :close).to(STDOUT, log_file)
    else
      log_io = log_file
    end
    @log = AppLogger.new(log_io)
    # DESIGN: I wish Auth module took care of this initialization
    OmniAuth.config.logger = log
  end

  # paths config/application.yml and config/application/environment/{appenv}.yml
  # will be searched for optional config files. Env-specific config will
  # override application.yml
  def load_config
    config_path = root.join(DEFAULT_PATHS[:config])
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

  def initialize_config
    @config = load_config
  end

  def run_env_initializers
    env_exec = paths.config.join("environment/#{env}.rb")
    if File.exists?(env_exec)
      require env_exec
    end
  end

  def request_thread_count
    if const_defined?('Puma') and Puma.respond_to?(:cli_config)
      Puma.cli_config.options[:max_threads]
    else
      2
    end
  end

  def define_routes(&block)
    @endpoint ||= Rack::Builder.new(&block)
  end

  def load_routes
    require root.join('config/routes')
  end
end
