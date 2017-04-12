class User < ActiveRecord::Base
  # establish_connection "scpr"
  # self.table_name = "auth_user"

  has_secure_password

  class << self
    def authenticate(username, password)
      self.find_by_username(username).try(:authenticate, password)
    end
  end

end