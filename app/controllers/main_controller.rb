class MainController < Controller

  # 2 paths: user exists, doesn't exist
  put '/profile' do
    require_authentication

    begin
      data = MultiJson.load(request.body.read, symbolize_keys: true)
      profile = data[:profile]
    rescue MultiJson::ParseError
    end

    halt 422, "profile is missing" unless profile

    profile.slice!(:name, :email, :image_url)
    user = current_user
    # Limit duplicate accounts
    # NOTE: A user could hijack another user's account by creating a new
    # identity then providing the target's email at profile confirm
    user ||= User.find_by(email: profile[:email])
    user ||= User.new

    user.update(profile)

    if !current_identity.user
      current_identity.user = user
      current_identity.save!
    end

    jbuilder :'data/user', locals: { user: user }
  end

  get '/dna.json' do
    jbuilder :'data/client_config'
  end

  get '/i18n.json' do
    content_type :json
    # currently dumping all translations,
    # try to make sure nothing private gets leaked
    App.i18n.to_json
  end

  get %r{^/(profile|login|gate)?$} do
    path = App.paths.client.join('index.html')
    if not File.exists?(path)
      raise "missing client index file"
    end
    File.read(path)
  end
end
