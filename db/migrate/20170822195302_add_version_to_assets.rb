class AddVersionToAssets < ActiveRecord::Migration[5.0]
  def change
    add_column :asset_host_core_assets, :version, :integer, default: 1
  end
end
