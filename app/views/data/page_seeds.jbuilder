if current_user
  json.userInfo do
    json.partial! :'data/user', user: current_user
  end
end

binding.pry
if current_identity
  json.iid current_identity.slug
end