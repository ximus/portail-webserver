class Identity < Model
  belongs_to :user

  class << self
    def from_omniauth(auth_hash)
      attrs = {
        provider_uid: auth_hash['uid'],
        provider:     auth_hash['provider']
      }
      model = where(attrs).first
      if model.nil?
        model = create(attrs)
      end
      model
    end
  end
end