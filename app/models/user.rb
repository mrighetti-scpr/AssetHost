class User

  include Mongoid::Document
  include Mongoid::Timestamps
  include ActiveModel::SecurePassword

  field :username,        type: String
  field :password_digest, type: String
  field :is_admin,        type: Boolean, default: false
  field :is_active,       type: Boolean, default: true
  field :permissions,     type: Array, default: [{resource: "assets", ability: "write"}]

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
    username = request.params["user_token"] && request.params["user_token"]["identification"] || request.params["user_token"]["username"]
    self.where(username: username).first
  end
  
  # def self.from_token_payload payload
  #   # Returns a valid user, `nil` or raise
  #   # e.g.
  #   #   self.find payload["sub"]
  #   byebug
  # end

  def as_json *args
    json = super
    json.delete("_id")
    json.delete("password_digest")
    json["id"] = self.id.to_s
    json
  end

  def to_token_payload
    json   = as_json
    output = {}
    output["sub"] = json["id"]
    json.delete("id")
    output["data"] = json
    output
  end

  def can? resource, ability
    return true if self.is_admin
    _resource = (self.permissions || []).find{|p| ActiveSupport::HashWithIndifferentAccess.new(p)[:resource] == resource}
    return false if !_resource
    _ability  = ActiveSupport::HashWithIndifferentAccess.new(_resource)[:ability]
    return false if !_ability
    return true if ability == _ability
    return true if (ability == "read" && _ability == "write")
    false
  end

end