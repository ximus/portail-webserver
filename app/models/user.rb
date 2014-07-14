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
  end

  def update_from_auth_hash(hash)
    info = hash[:info]
    self.email ||= info[:email]
    self.name  ||= info[:first_name] || info[:name]
    self.image_url = info[:image_url] if info[:image_url]
  end

  def vetted?
    !vetted_by.nil?
  end

  def using_gravatar?
    image_url && image_url.match('gravatar.com')
  end
end