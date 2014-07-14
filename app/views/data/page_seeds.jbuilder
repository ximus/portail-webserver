if current_user
  json.userInfo do
    json.partial! :'data/user', user: current_user
  end
end

if current_identity
  json.iid current_identity.slug
end