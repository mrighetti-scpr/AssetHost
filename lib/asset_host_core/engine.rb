require 'rails'
require 'rake' # I don't know why, please don't ask
require 'resque'
require 'thinking_sphinx'
require 'paperclip'

require 'coffee-rails'
require 'sass-rails'
require 'eco'
require 'bootstrap-sass'

require 'simple_form'
require 'kaminari'


module AssetHostCore
  class Engine < ::Rails::Engine
    @@mpath = nil
    @@redis_pubsub = nil
    
    isolate_namespace AssetHostCore

    # initialize our config hash
    config.assethost = ActiveSupport::OrderedOptions.new
    
    # -- post-initialization setup -- #

    config.after_initialize do
      # work around an issue where TS isn't seeing model directories if Rails hasn't appended the trailing slash
      ::ThinkingSphinx::Configuration.instance.model_directories << File.expand_path("../../../app/models",__FILE__) + "/"
      
      # set our resque job's queue
      AssetHostCore::ResqueJob.instance_variable_set :@queue, Rails.application.config.assethost.resque_queue
    end
    
    # add resque's rake tasks
    rake_tasks do
      require "resque/tasks"
    end

    #----------
    
    def self.mounted_path
      if @@mpath
        return @@mpath.spec.to_s == '/' ? '' : @@mpath.spec.to_s
      end
      
      # -- find our path -- #
      
      route = Rails.application.routes.routes.detect do |route|
        route.app == self
      end
        
      if route
        @@mpath = route.path
      end

      return @@mpath.spec.to_s == '/' ? '' : @@mpath.spec.to_s
    end
    
    #----------
    
    def self.redis_pubsub
      if Rails.application.config.assethost.redis_pubsub && Rails.application.config.assethost.redis_pubsub.is_a?(Hash)
        if @@redis_pubsub
          return @@redis_pubsub
        end
        
        return @@redis_pubsub ||= Redis.new(Rails.application.config.assethost.redis_pubsub[:server])
      else
        return false
      end
    end
    
    #----------
    
    def self.redis_publish(data)
      if r = self.redis_pubsub
        return r.publish(Rails.application.config.assethost.redis_pubsub[:key]||"AssetHost",data.to_json)
      else
        return false
      end
    end
  end
end
