module AssetHostCore
  class ApiUserPermission < ActiveRecord::Base
    belongs_to :api_user
    belongs_to :permission
  end
end
