ActiveRecord::Schema.define do

  create_table "asset_host_core_api_users", :force => true do |t|
    t.string   "name",                 :null => false
    t.string   "authentication_token"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_active"
    t.datetime "last_authenticated"
  end

  create_table "asset_host_core_asset_outputs", :force => true do |t|
    t.integer  "asset_id",                          :null => false
    t.integer  "output_id",                         :null => false
    t.string   "fingerprint"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "width"
    t.integer  "height"
    t.string   "image_fingerprint", :default => "", :null => false
  end

  add_index "asset_host_core_asset_outputs", ["asset_id", "output_id"], :name => "asset_id", :unique => true

  create_table "asset_host_core_assets", :force => true do |t|
    t.string   "title"
    t.text     "caption"
    t.string   "owner"
    t.string   "url"
    t.integer  "creator_id",         :default => 1,        :null => false
    t.text     "notes"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.string   "image_copyright"
    t.string   "image_fingerprint"
    t.string   "image_title"
    t.string   "image_description"
    t.datetime "image_updated_at"
    t.string   "image_gravity",      :default => "Center", :null => false
    t.integer  "image_width"
    t.integer  "image_height"
    t.integer  "image_file_size"
    t.integer  "image_version"
    t.datetime "image_taken"
    t.integer  "native_id"
    t.string   "native_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_hidden",          :default => false,    :null => false
  end

  create_table "asset_host_core_brightcove_videos", :force => true do |t|
    t.integer  "videoid",    :limit => 8, :null => false
    t.integer  "length"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "asset_host_core_outputs", :force => true do |t|
    t.string   "code",                          :null => false
    t.string   "size",                          :null => false
    t.string   "extension",                     :null => false
    t.boolean  "is_rich",    :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "prerender",  :default => false, :null => false
  end

  create_table "asset_host_core_permissions", :force => true do |t|
    t.string   "resource"
    t.string   "ability"
    t.string   "user_type"
    t.string   "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "asset_host_core_vimeo_videos", :force => true do |t|
    t.string   "videoid"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "asset_host_core_youtube_videos", :force => true do |t|
    t.string   "videoid"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

end
