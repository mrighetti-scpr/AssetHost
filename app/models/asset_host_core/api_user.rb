require 'securerandom'

module AssetHostCore
  class ApiUser < ActiveRecord::Base
    TOKEN_LENGTH = 20

    has_many :permissions, as: :user

    before_create :generate_api_token, if: -> {
      self.authentication_token.blank?
    }

    class << self
      def authenticate(auth_token)
        self.find_by_authentication_token(auth_token)
      end
    end


    def may?(ability, resource)
      !!self.permissions.find do |p|
        p.resource == resource.to_s && p.ability == ability
      end
    end


    def generate_api_token
      self.authentication_token = SecureRandom.urlsafe_base64
    end

    def generate_api_token!
      generate_api_token and save
    end
  end
end
