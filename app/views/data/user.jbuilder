json.extract! user, :name, :image_url
json.vetted user.vetted?

# not sure this is still used
if user.email.nil? || user.name.nil?
  json.insufficiant_profile true
end