Combustion::Application.configure do
  config.assethost = ActiveSupport::OrderedOptions.new
  config.assethost.server         = "a.scpr.org"


#  config.assethost.redis_pubsub   = { server: { host: "127.0.0.1", port: 6379, db: 0 }, key: "AHSCPR" }

  config.assethost.paperclip_options = {
    :path           => ':rails_root/public/images/:id_:fingerprint_:sprint.:extension',
    :url            => "http://#{config.assethost.server}/i/:fingerprint/:id-:style.:extension",
    :storage        => 'filesystem',
    :use_timestamp  => false
  }

  config.assethost.resque_queue   = :ahhost
end


AssetHostCore.hooks do |config|
  config.current_user_method do
    begin
      @current_user ||= User.find(session[:user_id])
    rescue ActiveRecord::RecordNotFound
      session[:user_id]   = nil
      @current_user       = nil
    end
  end
  
  config.sign_out_path do
    Rails.application.routes.url_helpers.logout_path
  end
  
  config.authentication_method do
    if !current_user
      session[:return_to] = request.fullpath
      redirect_to Rails.application.routes.url_helpers.login_path
      false
    end
  end
  
  config.api_authentication_method do
    if !current_api_user && !current_user
      head :unauthorized
    end
  end
end


AssetHostCore.configure do |config|
  config.flickr_api_key       = "flackrs"
  config.google_api_key      = 'goggles'
  config.brightcove_api_key   = "brightcovs"

  config.thumb_size   = "thumb"
  config.modal_size   = "lead"
  config.detail_size  = "wide"
end
