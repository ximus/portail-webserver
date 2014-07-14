if @user
  json.user do
    json.partial! :'data/user', user: @user
  end
else
  json.signupSeed @signup_seed
end

json.iid @identity.slug