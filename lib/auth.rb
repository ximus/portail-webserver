class Auth
  class << self
    def providers
      config.providers
    end

    def config
      App.config.auth
    end
  end
end