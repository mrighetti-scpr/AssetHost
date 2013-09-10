require 'securerandom'

module AssetHostCore
  class ApiUser < ActiveRecord::Base
    TOKEN_LENGTH = 20

    has_many :permissions, as: :user

    before_save :generate_api_token, on: :create

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


    private

    def generate_api_token
      self.api_token = SecureRandom.urlsafe_base64
    end
  end
end
