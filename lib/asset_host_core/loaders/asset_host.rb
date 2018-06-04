module AssetHostCore
  module Loaders
    class AssetHost < Base
      SOURCE = "AssetHost"

      def self.build_from_url(url)
        matches = [
          %r{\/i\/[^\/]+\/(?<id>\d+)-},
          %r{\/api\/assets\/(?<id>\d+)}
        ]

        match = nil

        if matches.find { |m| match = url.match(m) }
          self.new(url: url, id: match[:id])
        else
          nil
        end
      end

      def load
        Asset.find(@id)
      end
    end
  end
end
