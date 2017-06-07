class MakeImageDescriptionsLonger < ActiveRecord::Migration[5.0]
  def up
    change_column :asset_host_core_assets, :image_description, :text
  end
  def down
    change_column :asset_host_core_assets, :image_description, :string
  end
end
