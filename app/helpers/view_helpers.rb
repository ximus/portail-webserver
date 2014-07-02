module ViewHelpers
  def app
    App.instance
  end

  def i18n
    app.i18n
  end

  def asset_path(logical_path)
    app.assets.basepath + '/' + app.assets[logical_path].digest_path
  end
end