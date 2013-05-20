require 'mime/types'
require 'brightcove-api'

module AssetHostCore
  module Loaders
    class Brightcove < Base
      
      def self.try_url(url)
        return nil if AssetHostCore.config.brightcove_api_key.blank?
        nil
      end

      #----------
      
      def load
        brightcove = ::Brightcove::API.new(AssetHostCore.config.brightcove_api_key)
        
        begin
          # get our video info
          response = brightcove.get("find_video_by_id", { :video_id => @id })
        rescue
          # invalid video...
          return nil
        end
        
        resp = response.parsed_response
        
        w = h = 0
        
        resp['renditions'].each do |r|
          if r['frameWidth'] > w
            w = r['frameWidth']
            h = r['frameHeight']
          end
        end

        @file = resp['videoStillURL']

        native = AssetHostCore::BrightcoveVideo.create(
          :videoid  => resp['id'],
          :length   => resp['length']
        )


        asset = AssetHostCore::Asset.new(
          :title          => resp["name"],
          :caption        => resp["shortDescription"],
          :owner          => "",
          :image_taken    => DateTime.strptime(resp["publishedDate"],"%Q"),
          :url            => nil,
          :notes          => "Brightcove import as ID #{resp['id']}",
          :image          => image_file,
          :native         => native
        )
        
        
        asset.save
        asset
      end
      

      #----------

      private
      
      def image_file
        @image_file ||= begin
          response = Net::HTTP.get_response(URI.parse(@file))

          file = Tempfile.new("IABrightcove", encoding: 'ascii-8bit')
          file << response.body
        end
      end
    end
  end
end
