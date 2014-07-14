class MainController < Controller

  # 2 paths: user exists, doesn't exist
  put '/profile' do
    require_authentication
    data = MultiJson.load(request.body.read, symbolize_keys: true)
    profile = data[:profile]

    halt 422 unless profile

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

  get '/*' do
    erb :index
  end
end