class MainController < Controller

  put '/profile' do
    require_auth

    profile = params[:profile].with_indifferent_access
    profile.slice!(:name, :email)
    current_user.update!(profile)
  end

  get '/*' do
    erb :index
  end
end