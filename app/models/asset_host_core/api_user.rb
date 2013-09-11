require 'securerandom'

module AssetHostCore
  class ApiUser < ActiveRecord::Base
    has_many :api_user_permissions
    has_many :permissions, through: :api_user_permissions

    validates_uniqueness_of :auth_token

    before_create :generate_auth_token, if: -> {
      self.auth_token.blank?
    }


    class << self
      def authenticate(auth_token)
        self.find_by_auth_token(auth_token)
      end
    end


    def may?(ability, resource)
      !!self.permissions.find do |p|
        p.resource == resource.to_s && p.ability == ability.to_s
      end
    end


    def generate_auth_token
      self.auth_token = SecureRandom.urlsafe_base64
    end

    def generate_auth_token!
      generate_auth_token and save
    end
  end
end
