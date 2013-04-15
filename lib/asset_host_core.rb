require "asset_host_core/engine"

require "paperclip"
require "paperclip/attachment"

require "asset_host_core/config"

require "asset_host_core/resque_job"
require "asset_host_core/asset_thumbnail"
require "asset_host_core/paperclip"

require "asset_host_core/loaders"
require "asset_host_core/loaders/base"
require "asset_host_core/loaders/asset"
require "asset_host_core/loaders/youtube"
require "asset_host_core/loaders/vimeo"
require "asset_host_core/loaders/brightcove"
require "asset_host_core/loaders/flickr"
require "asset_host_core/loaders/url"

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

if Object.const_defined?("ActiveRecord")
  ActiveRecord::Base.send(:include, AssetHostCore::Paperclip)
end
