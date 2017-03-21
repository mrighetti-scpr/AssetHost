class ApiUserPermission < ActiveRecord::Base
  self.table_name = "asset_host_core_api_user_permissions"
  
  belongs_to :api_user
  belongs_to :permission
end

