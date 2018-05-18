class RemoveApiUsers < ActiveRecord::Migration[5.0]
  def up
    drop_table "asset_host_core_api_user_permissions"
    drop_table "asset_host_core_api_users"
    drop_table "asset_host_core_permissions"
  end
  def down
    create_table "asset_host_core_api_user_permissions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
      t.integer  "api_user_id"
      t.integer  "permission_id"
      t.datetime "created_at",    null: false
      t.datetime "updated_at",    null: false
      t.index ["api_user_id"], name: "index_asset_host_core_api_user_permissions_on_api_user_id", using: :btree
      t.index ["permission_id"], name: "index_asset_host_core_api_user_permissions_on_permission_id", using: :btree
    end
  
    create_table "asset_host_core_api_users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
      t.string   "name",               null: false
      t.string   "auth_token"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.boolean  "is_active"
      t.datetime "last_authenticated"
      t.string   "email"
      t.index ["auth_token", "is_active"], name: "index_asset_host_core_api_users_on_auth_token_and_is_active", using: :btree
    end

    create_table "asset_host_core_permissions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
      t.string   "resource"
      t.string   "ability"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["resource", "ability"], name: "index_asset_host_core_permissions_on_resource_and_ability", using: :btree
    end

  end
end
