class User < ActiveRecord::Base
  if config = Rails.configuration.database_configuration[Rails.env]["users"]
    establish_connection(config) if config["host"].present?
    if table_name = config["table_name"]
      self.table_name = table_name
    end
  end

  has_secure_password

  class << self
    def authenticate(username, password)
      self.find_by_username(username).try(:authenticate, password)
    end
  end

end