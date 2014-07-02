class Auth
  class << self
    def providers
      config.providers.keys
    end

    def omniauth_providers
      Proc.new do
        # Dynamically load providers from app config
        config.providers.each do |(provider_id, config)|
          provider(provider_id, config.token, config.secret)
        end
      end
    end

    def config
      App.instance.config.auth
    end
  end
end