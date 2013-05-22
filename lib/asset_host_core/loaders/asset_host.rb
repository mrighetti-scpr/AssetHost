module AssetHostCore
  module Loaders
    class AssetHost < Base
      SOURCE = "AssetHost"

      def self.build_from_url(url)
        assethost_root = "#{Rails.application.config.assethost.server}#{AssetHostCore::Engine.mounted_path}"

        matches = [
          %r{#{assethost_root}\/i\/[^\/]+\/(?<id>\d+)-},
          %r{#{assethost_root}\/api\/assets\/(?<id>\d+)}
        ]

        match = nil
        
        if matches.find { |m| match = url.match(m) }
          self.new(url: url, id: match[:id])
        else
          nil
        end
      end
      
      #--------------

      def load
        AssetHostCore::Asset.find_by_id(@id)
      end
    end
  end
end
