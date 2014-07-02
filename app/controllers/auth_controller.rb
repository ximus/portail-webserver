class AuthController < Controller


  # TODO: potential failure path needs thinking, also in the client
  get '/:provider/callback' do
    auth_hash = env['omniauth.auth']

    @identity = Identity.from_omniauth(auth_hash)

    @user = @identity.user
    if @user.nil?
      @signup_seed = signup_seed(auth_hash)
    end

    session[:iid] = @identity.slug.to_s

    erb :'auth_callback_popup'
  end

  post '/logout' do
    require_authentication
    session[:iid] = nil
  end

  def signup_seed(auth_hash)
    ret = {}
    info = auth_hash[:info]
    ret[:email] ||= info[:email]
    ret[:name]  ||= [info[:first_name], info[:last_name]].join(' ') || info[:name]
    ret[:image_url] = info[:image_url] if info[:image_url]
    ret
  end
end