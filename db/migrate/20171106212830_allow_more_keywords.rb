class AllowMoreKeywords < ActiveRecord::Migration[5.0]
  def up
    change_column :asset_host_core_assets, :keywords, :text
  end
  def down
    change_column :asset_host_core_assets, :keywords, :string
  end
end
