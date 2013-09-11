module AssetHostCore
  class Permission < ActiveRecord::Base
    ABILITIES = [
      :read,
      :write
    ]

    attr_accessible :resource, :ability

    has_many :api_user_permissions
    has_many :api_users, through: :api_user_permissions

    validates :resource, :ability, presence: true

    def to_s
      "[#{self.resource}] #{self.ability}"
    end
  end
end
