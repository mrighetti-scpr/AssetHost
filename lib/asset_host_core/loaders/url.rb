require 'mime/types'
require 'net/http'
require 'cgi'

module AssetHostCore
  module Loaders
    class URL < Base
      SOURCE = "URL"

      #-----------

      def self.try_url(url)
        uri       = URI.parse(url)
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
        filename = @url.match(/\/(.+)$/)[0]

        # build asset
        asset = AssetHostCore::Asset.new(
          :title    => filename,
          :url      => @url,
          :notes    => "Fetched from URL: #{@url}"
        )
        
        # add image
        asset.image = image_file
        
        # save Asset
        asset.save
        asset
      end

      #----------

      private
      
      def image_file
        @image_file ||= begin
          response = Net::HTTP.get_response(URI.parse(@url))

          file = Tempfile.new("IAfromurl", encoding: 'ascii-8bit')
          file << response.body
        end
      end
    end
  end
end
