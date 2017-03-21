require 'mime/types'
require 'brightcove-api'

module AssetHostCore
  module Loaders
    class Brightcove < Base
      SOURCE = "Brightcove"

      # Since brightcove videos don't have canoncial URL's,
      # we have to make-up a way to import them
      def self.build_from_url(url)
        return nil if AssetHostCore.config.brightcove_api_key.blank?

        url.match(/brightcove:(?<id>\d+)/) do |m|
          self.new(url: nil, id: m[:id])
        end
      end

      #----------

      # Brightcove videos don't have URL's
      def load
        brightcove = ::Brightcove::API.new(AssetHostCore.config.brightcove_api_key)

        # get our video info
        response = brightcove.get("find_video_by_id", { video_id: @id }).parsed_response

        native = AssetHostCore::BrightcoveVideo.create(
          :videoid  => response['id'],
          :length   => response['length']
        )

        @image_url = response['videoStillURL']

        asset = AssetHostCore::Asset.new(
          :title          => response["name"],
          :caption        => response["shortDescription"],
          :owner          => "KPCC",
          :image_taken    => DateTime.strptime(response["publishedDate"],"%Q"),
          :url            => nil,
          :notes          => "Imported from Brightcove: #{@id}",
          :image          => image_file,
          :native         => native
        )


        asset.save!
        image_file.close(true)
        asset
      end


      #----------

      private

      def image_file
        @image_file ||= begin
          tempfile = Tempfile.new('ah-brightcove', encoding: "ascii-8bit")
          open(@image_url) { |f| tempfile.write(f.read) }
          tempfile.rewind

          tempfile
        end
      end
    end
  end
end
