module ViewHelpers
  def i18n
    App.i18n
  end

  def asset_path(logical_path)
    App.assets.basepath + '/' + App.assets[logical_path].digest_path
  end

  def insert(view)
    File.read(settings.views.join(view.to_s))
  end
end