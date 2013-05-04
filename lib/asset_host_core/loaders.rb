require "asset_host_core/loaders/base"
require "asset_host_core/loaders/asset"
require "asset_host_core/loaders/youtube"
require "asset_host_core/loaders/vimeo"
require "asset_host_core/loaders/brightcove"
require "asset_host_core/loaders/flickr"
require "asset_host_core/loaders/url"

module AssetHostCore
  module Loaders

    MODULES = [
      Asset,
      YouTube,
      Flickr,
      Brightcove,
      URL
    ]

    class << self
      def load(url)
        match = nil

        MODULES.find { |klass| match = klass.parse_url(url) }
        
        if match
          loader = klass.new(id: match[:id], url: url)
          asset  = loader.load
        end
        
        asset
      end
      

      def classes
        puts "Classes: " + MODULES.to_s
      end
    end
  end
end
