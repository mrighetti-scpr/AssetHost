class User < ActiveRecord::Base
  has_secure_password
  attr_accessible :username, :password

  class << self
    def authenticate(username, password)
      self.find_by_username(username).try(:authenticate, password)
    end
  end
end
