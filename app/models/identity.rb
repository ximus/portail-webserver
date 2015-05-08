class Identity < Model
  belongs_to :user
  serialize :user_info

  class << self
    def from_omniauth(auth_hash)
      attrs = {
        provider_uid: auth_hash['uid'],
        provider:     auth_hash['provider']
      }
      model = where(attrs).first
      if model.nil?
        attrs[:user_info] = User.extract_from_auth_hash(auth_hash)
        model = create(attrs)
      end
      model
    end
  end
end
