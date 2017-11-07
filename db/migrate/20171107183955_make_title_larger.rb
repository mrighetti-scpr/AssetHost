class MakeTitleLarger < ActiveRecord::Migration[5.0]
  def up
    change_column :asset_host_core_assets, :title, :text
  end
  def down
    change_column :asset_host_core_assets, :title, :string
  end
end
