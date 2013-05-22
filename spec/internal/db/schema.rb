ActiveRecord::Schema.define do
  create_table :asset_host_core_outputs, force: true do |t|
    t.string :code
    t.string :size
    t.string :extension
    t.boolean :is_rich
    t.boolean :prerender
    t.timestamps
  end

  create_table :asset_host_core_assets do |t|
    t.string :title
    t.string :owner
    t.string :url
    t.string :image_file_name
    t.string :image_content_type
    t.string :image_copyright
    t.string :image_fingerprint
    t.string :image_title
    t.string :image_description
    t.string :image_gravity
    t.text :caption
    t.text :notes
    t.belongs_to :creator, :null => true
    t.belongs_to :native, :polymorphic => true
    t.integer :image_width
    t.integer :image_height
    t.integer :image_file_size
    t.integer :image_version
    t.datetime :image_updated_at
    t.datetime :image_taken
    t.boolean :is_hidden, :default => false, :null => false
    t.timestamps
  end

  create_table :asset_host_core_asset_outputs do |t|
    t.belongs_to :asset, :null => false
    t.belongs_to :output, :null => false
    t.string :fingerprint
    t.string :image_fingerprint, :null => false
    t.integer :width
    t.integer :height
    t.timestamps
  end

  create_table :asset_host_core_brightcove_videos do |t|
    t.integer :videoid, :null => false
    t.integer :length
    t.timestamps
  end

  create_table :asset_host_core_youtube_videos do |t|
    t.integer :videoid, :null => false
    t.timestamps
  end

end
