Combustion::Application.configure do
  config.assethost = ActiveSupport::OrderedOptions.new
  config.assethost.server         = "a.scpr.org"

  config.assethost.flickr_api_key   = "flackrs"
  config.assethost.youtube_api_key  = 'youtoobs'
  config.assethost.brightcove       = "brightcovs"

  config.assethost.redis_pubsub   = { server: { host: "127.0.0.1", port: 6379, db: 0 }, key: "AHSCPR" }

  config.assethost.paperclip_options = {
    :path           => ':rails_root/public/images/:id_:fingerprint_:sprint.:extension',
    :url            => "http://#{config.assethost.server}/i/:fingerprint/:id-:style.:extension",
    :storage        => 'filesystem',
    :use_timestamp  => false
  }

  config.assethost.resque_queue   = :ahhost
  config.assethost.thumb_size     = "thumb"
  config.assethost.modal_size     = "lead"
  config.assethost.detail_size    = "wide"
end
