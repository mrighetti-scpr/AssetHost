require_relative 'boot'

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
# require "action_mailer/railtie"
require "action_view/railtie"
# require "action_cable/engine"
require "sprockets/railtie"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module AssetHost
  class Application < Rails::Application
    require "#{Rails.root}/lib/asset_host_core"
    require "#{Rails.root}/lib/photographic_memory"
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.filter_parameters += [:password]

    # config.api = Hashie::Mash.new(YAML.load_file("#{Rails.root}/config/api_config.yml")[Rails.env])

    @@mpath = nil
    @@redis_pubsub = nil

    # initialize our config hash
    config.assethost = ActiveSupport::OrderedOptions.new

    # -- post-initialization setup -- #

    config.after_initialize do
      # set our resque job's queue
      AssetHostCore::ResqueJob.instance_variable_set :@queue, AssetHostCore.config.resque_queue || "assethost"
    end

    initializer 'asset_host_core.register_processor' do
      Paperclip.configure do |c|
        # Since this isn't in the standard location that Paperclip
        # looks for it (lib/paperclip_processors), we should just
        # register is manually to be safe.
        c.register_processor :asset_thumbnail, Paperclip::AssetThumbnail
      end
    end

    # add resque's rake tasks
    rake_tasks do
      require "resque/tasks"
    end

    def self.redis_pubsub
      if AssetHostCore.config.redis_pubsub
        if @@redis_pubsub
          return @@redis_pubsub
        end

        return @@redis_pubsub ||= Redis.new(AssetHostCore.config.redis_pubsub[:server])
      else
        return false
      end
    end

    def self.redis_publish(data)
      if r = self.redis_pubsub
        return r.publish(AssetHostCore.config.redis_pubsub[:key]||"AssetHost",data.to_json)
      else
        return false
      end
    end


  end
end
