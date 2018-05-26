class User

  include Mongoid::Document
  include Mongoid::Timestamps
  include ActiveModel::SecurePassword

  field :username,        type: String
  field :password_digest, type: String
  field :is_admin,        type: Boolean, default: false
  field :permissions,     type: Hash, default: {"assets" => "write"}

  validates_presence_of :password, on: :create

  has_secure_password

  class << self
    def column_names
      return ["id", "username", "password_digest", "is_admin"]
    end
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

  def can? resource, ability
    return true if self.is_admin
    _resource = ActiveSupport::HashWithIndifferentAccess.new(self.permissions || {})[resource]
    return false if !_resource
    _ability  = ActiveSupport::HashWithIndifferentAccess.new(_resource || {})[ability]
    return false if !_ability
    return true if ability == _ability
    return true if (ability == "read" && _ability == "write")
    false
  end

end