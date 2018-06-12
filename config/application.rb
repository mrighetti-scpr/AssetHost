require_relative 'boot'

require "rails"
require "active_model/railtie"
require "active_job/railtie"
require "action_controller/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

require "dotenv"
Dotenv.overload(".env.#{Rails.env}")

module AssetHost
  class Application < Rails::Application
    require "#{Rails.root}/lib/asset_host_core"
    require "#{Rails.root}/lib/asset_host_utils"
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.filter_parameters += [:password, :token, :jwt]

    config.secret_key_base = ENV["ASSETHOST_SECRET_KEY_BASE"] || SecureRandom.hex(64)

    # This is not referring to assets as in the asset model, but the
    # frontend resources like scripts, stylesheets, and other goodies.
    # Because we want a route called "assets" for our asset model, we
    # have to name this route prefix to something else.
    # config.assets.prefix = "/resources"

    # initialize our config hash
    config.assethost = ActiveSupport::OrderedOptions.new

    config.elasticsearch_index = "assethost-assets"

    config.active_job.queue_adapter = :resque
    config.resque_queue             = ENV["ASSETHOST_RESQUE_QUEUE"] || :assets

    config.action_dispatch.default_headers.clear

    if Rails.env.development?
      config.web_console.whitelisted_ips = ["127.0.0.1","172.21.0.1"]
    end

    ENV["ELASTICSEARCH_URL"] ||= ENV["ASSETHOST_ELASTICSEARCH_HOST"]

    config.middleware.delete ActionDispatch::Cookies
    config.middleware.delete ActionDispatch::Session::CookieStore

    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins "*"
        resource "*", headers: :any, methods: [:get, :post, :put, :patch, :options]
      end
    end

  end
end
