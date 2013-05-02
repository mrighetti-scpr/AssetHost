require "asset_host_core/engine"

require "paperclip"
require "asset_host_core/paperclip/attachment"

require "asset_host_core/config"

require "asset_host_core/resque_job"
require "asset_host_core/asset_thumbnail"
require "asset_host_core/model_methods"

require "asset_host_core/loaders"

module AssetHostCore
  class << self
    # Pass url to our loader plugins and see if anyone bites.  Our first 
    # loader should always be the loader that handles our own API urls 
    # for existing assets.
    def as_asset(url)
      AssetHostCore::Loaders.load(url)
    end
  end
  
  def self.hooks(&block)
    block.call(AssetHostCore::Config)
  end
end

ActiveRecord::Base.send(:include, AssetHostCore::ModelMethods)
