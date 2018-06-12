require 'mime/types'
require 'net/http'
require 'cgi'

module AssetHostCore
  module Loaders
    class URL < Base
      SOURCE = "URL"

      def self.build_from_url(url)
        uri = URI.parse(url)
        return nil unless uri.is_a?(URI::HTTP)
        connection = Faraday.new(uri) do |b|
          b.use FaradayMiddleware::FollowRedirects
          b.adapter :net_http
        end
        response = connection.head

        # Check that it's actually an image we're grabbing
        self.new(url: url, id: url) if (response.headers["content-type"] || "").match(/image/)
      end

      def load
        filename     = File.basename URI.parse(@url).path
        content_type = AssetHostUtils.guess_content_type(filename)
        return if !content_type
        # build asset
        asset = Asset.new(
          file: image_file,
          title: filename,
          url: @url,
          image_file_name: filename,
          image_content_type: content_type,
          notes: "Fetched from URL: #{@url}"
        )
        asset.save!
        asset
      end

      private

      def image_file
        connection = Faraday.new(@url) do |b|
          b.use FaradayMiddleware::FollowRedirects
          b.adapter :net_http
        end
        @image_file ||= StringIO.new(connection.get.body)
      end
    end
  end
end
