module AssetHostCore
  module Loaders
    class AssetHost < Base
      SOURCE = "AssetHost"

      def self.build_from_url(url)
        assethost_root = "#{Rails.application.config.host}"

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
        Asset.where(id: @id).first!
      end
    end
  end
end
