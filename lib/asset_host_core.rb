require "asset_host_core/resque_job"
# require "asset_host_core/engine"
# require "asset_host_core/processing"
require "asset_host_core/paperclip"
require "asset_host_core/config"
require "asset_host_core/model_methods"
require 'google/api_client'
require 'open-uri'
require 'faraday_middleware'
require "asset_host_core/loaders"

module AssetHostCore
  class << self
    # Pass url to our loader plugins and see if anyone bites.  Our first
    # loader should always be the loader that handles our own API urls
    # for existing assets.
    def as_asset(url)
      AssetHostCore::Loaders.load(url)
    end

    #----------------

    def configure
      yield config
    end

    #----------------

    def config
      @config ||= AssetHostCore::Config.new
    end

    def hooks(&block)
      block.call(AssetHostCore::Config)
    end
  end
end

ActiveRecord::Base.send(:include, AssetHostCore::ModelMethods)
