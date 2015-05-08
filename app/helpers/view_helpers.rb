module ViewHelpers
  def i18n
    App.i18n
  end

  def asset_path(logical_path)
    App.assets.basepath + '/' + App.assets[logical_path].digest_path
  end

  # to be deprecated with new ui
  def insert(view)
    File.read(settings.views.join(view.to_s))
  end

  # need to prioritize this
  def client_auth_config
    ret = {}
    ret[:url] = "/auth/{{omniauth_id}}"
    ret[:providers] = App.config.auth.providers.map do |id, provider|
      {id: id, omniauth_id: provider[:omniauth][:id]}
    end
    ret
  end
end
