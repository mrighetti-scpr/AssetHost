module AssetHostCore
  class Permission < ActiveRecord::Base
    belongs_to :user, polymorphic: true
  end
end
