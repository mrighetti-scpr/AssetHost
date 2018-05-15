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

  if self.column_names.include?("is_superuser") && !self.column_names.include?("is_admin")
    alias_attribute :is_admin, :is_superuser
  end

  def self.from_token_request request
    username = request.params["user_token"] && request.params["user_token"]["username"]
    self.where(username: username).first
  end
  
  # def self.from_token_payload payload
  #   # Returns a valid user, `nil` or raise
  #   # e.g.
  #   #   self.find payload["sub"]
  #   byebug
  # end

end