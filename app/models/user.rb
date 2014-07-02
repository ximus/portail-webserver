class User < Model
  GRAVATAR_URL_BASE = 'http://www.gravatar.com/avatar/'

  has_many :identities

  before_validation do
    if email.present? && changed.include?('email')
      self.image_url = GRAVATAR_URL_BASE + Digest::MD5.hexdigest(email)
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
end