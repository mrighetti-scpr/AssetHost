module AssetHostCore
  module Loaders
    MODULES = [
      "Asset",
      "Brightcove",
      "Flickr",
      "YouTube",
      "URL"
    ]

    class << self
      def load(url)
        asset = nil

        MODULES.each do |klass| 
          if loader = klass.constantize.valid?(url)
            asset = loader.load
            break
          end
        end
        
        return asset
      end
      

      def classes
        puts "Classes: " + @@discovered.to_s
      end
    end
  end
end

require "asset_host_core/loaders/base"
require "asset_host_core/loaders/asset"
require "asset_host_core/loaders/youtube"
require "asset_host_core/loaders/vimeo"
require "asset_host_core/loaders/brightcove"
require "asset_host_core/loaders/flickr"
require "asset_host_core/loaders/url"
