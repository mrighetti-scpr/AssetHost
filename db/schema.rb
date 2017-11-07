# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20171107183955) do

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

  create_table "asset_host_core_asset_outputs", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer  "asset_id",                       null: false
    t.integer  "output_id",                      null: false
    t.string   "fingerprint"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "width"
    t.integer  "height"
    t.string   "image_fingerprint", default: "", null: false
    t.index ["asset_id", "output_id"], name: "asset_id", unique: true, using: :btree
    t.index ["output_id"], name: "index_asset_host_core_asset_outputs_on_output_id", using: :btree
  end

  create_table "asset_host_core_assets", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.text     "title",              limit: 65535
    t.text     "caption",            limit: 65535
    t.string   "owner"
    t.string   "url"
    t.integer  "creator_id",                       default: 1,        null: false
    t.text     "notes",              limit: 65535
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.string   "image_copyright"
    t.string   "image_fingerprint"
    t.string   "image_title"
    t.text     "image_description",  limit: 65535
    t.datetime "image_updated_at"
    t.string   "image_gravity",                    default: "Center", null: false
    t.integer  "image_width"
    t.integer  "image_height"
    t.integer  "image_file_size"
    t.integer  "image_version"
    t.datetime "image_taken"
    t.integer  "native_id"
    t.string   "native_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_hidden",                        default: false,    null: false
    t.text     "keywords",           limit: 65535
    t.integer  "version",                          default: 1
  end

  create_table "asset_host_core_brightcove_videos", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.bigint   "videoid",    null: false
    t.integer  "length"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "asset_host_core_outputs", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string   "code",                       null: false
    t.string   "size",                       null: false
    t.string   "extension",                  null: false
    t.boolean  "is_rich",    default: true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "prerender",  default: false, null: false
    t.index ["code"], name: "index_asset_host_core_outputs_on_code", using: :btree
  end

  create_table "asset_host_core_permissions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string   "resource"
    t.string   "ability"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["resource", "ability"], name: "index_asset_host_core_permissions_on_resource_and_ability", using: :btree
  end

  create_table "asset_host_core_vimeo_videos", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string   "videoid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "asset_host_core_youtube_videos", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string   "videoid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "username"
    t.boolean  "is_admin",                       null: false
    t.boolean  "can_login",       default: true, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "password_digest"
  end

end
