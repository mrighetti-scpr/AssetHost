class User < ActiveRecord::Base
  # establish_connection "scpr"
  # self.table_name = "auth_user"

  has_secure_password
  #hack
  # attr_accessible :username, :password

  class << self
    def authenticate(username, password)
      self.find_by_username(username).try(:authenticate, password)
    end
  end

  # AssetHost requires an `is_admin?` field, but our database uses
  # `is_superuser?`.

  #HACK
  #^^ in this case, we do have the is_admin field
  # def is_admin?
  #   self.is_superuser?
  # end
end