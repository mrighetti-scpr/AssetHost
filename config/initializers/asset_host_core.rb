AssetHostCore.hooks do |config|
  # config.current_user_method do
  #   begin
  #     @current_user ||= User.where(can_login: true).find(session[:user_id])
  #   rescue ActiveRecord::RecordNotFound
  #     session[:user_id]   = nil
  #     @current_user       = nil
  #   end
  # end

  # config.sign_out_path do
  #   Rails.application.routes.url_helpers.logout_path
  # end

  # config.authentication_method do
  #   if !current_user
  #     session[:return_to] = request.fullpath
  #     redirect_to Rails.application.routes.url_helpers.login_path
  #     false
  #   end
  # end

  # config.api_authentication_method do
  #   if !current_api_user && !current_user
  #     head :unauthorized
  #   end
  # end
end


AssetHostCore.configure do |config|
  # config.flickr_api_key       = Rails.application.secrets['flickr_api_key']
  # config.brightcove_api_key   = Rails.application.secrets['brightcove_api_key']
  # config.google_api_key       = Rails.application.secrets['google_api_key']

  config.thumb_size           = "lsquare"
  config.modal_size           = "small"
  config.detail_size          = "eight"

  # config.elasticsearch_index  = "assethost-assets"

  config.paperclip_options    = Rails.application.config.assethost.paperclip_options
  # config.server               = Rails.application.config.assethost.server
  config.redis_pubsub         = Rails.application.secrets['pubsub'].symbolize_keys

  config.resque_queue         = :assets
end
