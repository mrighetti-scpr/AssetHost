class ExpandAssetFields < ActiveRecord::Migration[5.0]
  def up
    change_column "asset_host_core_assets", :title,             :text, :limit => 65535
    change_column "asset_host_core_assets", :caption,           :text, :limit => 65535
    change_column "asset_host_core_assets", :image_title,       :text, :limit => 65535
    change_column "asset_host_core_assets", :image_description, :text, :limit => 65535
    change_column "asset_host_core_assets", :notes,             :text, :limit => 65535
    change_column "asset_host_core_assets", :keywords,          :text, :limit => 65535
  end

  def down
  end
end
