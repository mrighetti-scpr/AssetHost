require 'mime/types'
require 'net/http'
require 'cgi'

module AssetHostCore
  module Loaders
    class URL < Base
      SOURCE = "URL"

      #-----------

      def self.build_from_url(url)
        uri = URI.parse(url)
        return nil unless uri.is_a?(URI::HTTP)

        response  = Net::HTTP.get_response(uri)

        # Check that it's actually an image we're grabbing
        if response.content_type.match(/image/)
          self.new(url: url, id: url)
        else
          nil
        end
      end

      #----------

      def load
        filename = File.basename(@url)
        # build asset
        asset = Asset.new(
          file: image_file,
          title: filename,
          url: @url,
          image_file_name: filename,
          image_content_type: AssetHostUtils.guess_content_type(filename),
          notes: "Fetched from URL: #{@url}"
        )
        asset.save!
        asset
      end

      #----------

      private

      def image_file
        @image_file ||= open(@url)
      end
    end
  end
end
