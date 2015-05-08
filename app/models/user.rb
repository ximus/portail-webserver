class User < Model
  GRAVATAR_URL_TEMPLATE = 'http://www.gravatar.com/avatar/%s?d=identicon'

  has_many :identities

  before_validation do
    if (image_url.blank? || using_gravatar?) &&
        email.present? && changed.include?('email')
      self.image_url = GRAVATAR_URL_TEMPLATE % Digest::MD5.hexdigest(email)
    end
  end

  class << self
    def root
      where('vetted_by = id').first
    end

    def extract_from_auth_hash(hash)
      {}.tap do |ret|
        info = hash[:info]
        ret[:email] ||= info[:email]
        ret[:name]  ||= [info[:first_name], info[:last_name]].join(' ').presence
        ret[:name]  ||= info[:name]
        ret[:image_url] = info[:image] if info[:image]
      end
    end
  end

  def update_from_auth_hash(hash)
    attrs = User.extract_from_auth_hash(hash)
    assign_attributes(attrs)
  end

  def vetted?
    !vetted_by.nil?
  end

  def using_gravatar?
    image_url && image_url.match('gravatar.com')
  end
end
