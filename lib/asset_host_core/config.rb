module AssetHostCore
  class Config
    attr_accessor :flickr_api_key,
                  :brightcove_api_key,
                  :google_api_key,
                  :thumb_size,
                  :modal_size,
                  :detail_size,
                  :elasticsearch_index,
                  :paperclip_options,
                  :server,
                  :resque_queue
  end
end
