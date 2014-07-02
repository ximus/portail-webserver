require 'securerandom'

class Model < ActiveRecord::Base
  self.abstract_class = true
  include ActiveUUID::UUID

  before_create do
    if self.respond_to?(:slug=) and slug.blank?
      self.slug = SecureRandom.uuid
    end
  end
end