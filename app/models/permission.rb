class Permission < ActiveRecord::Base
  self.table_name = "asset_host_core_permissions"

  ABILITIES = [
    :read,
    :write
  ]

  has_many :api_user_permissions
  has_many :api_users, through: :api_user_permissions

  validates :resource, :ability, presence: true

  def to_s
    "[#{self.resource}] #{self.ability}"
  end
end
