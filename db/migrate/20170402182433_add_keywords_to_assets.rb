class AddKeywordsToAssets < ActiveRecord::Migration[5.0]
  def change
    add_column "asset_host_core_assets", :keywords, :string
  end
end
