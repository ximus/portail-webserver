class AuthController < Controller


  # TODO: potential failure path needs thinking, also in the client
  get '/auth/:provider/callback' do
    auth_hash = env['omniauth.auth']

    @identity = Identity.from_omniauth(auth_hash)

    @user = @identity.user
    if @user.nil?
      @signup_seed = signup_seed(auth_hash)
    end

    session[:iid] = @identity.slug

    erb :'auth_callback_popup'
  end

  post '/auth/logout' do
    require_authentication
    session[:iid] = nil
  end

  def signup_seed(auth_hash)
    User.extract_from_auth_hash(auth_hash)
  end
end
