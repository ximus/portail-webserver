json.iid identity.slug

json.extract! user, :name, :image_url
json.vetted user.vetted?

if user.email.nil? || user.name.nil?
  json.insufficiant_profile true
end