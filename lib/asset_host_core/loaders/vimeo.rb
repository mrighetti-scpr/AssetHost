module AssetHostCore
  module Loaders
    class Vimeo < Base
      SOURCE = "Vimeo"

      #----------------

      def self.build_from_url(url)
        # Don't need a key just to read from the public API
        url.match(/vimeo\.com\/(?<id>\d+)/i) do |m|
          self.new(url: url, id: m[:id])
        end
      end

      #----------------

      def load
        data = fetch_data

        video = data[0]
        return nil if !video

        native = AssetHostCore::VimeoVideo.create(
          :videoid => video["id"]
        )

        asset = AssetHostCore::Asset.new(
          :image          => image_file(video["thumbnail_large"]),
          :title          => video["title"],
          :caption        => video["title"], # Description is too long
          :url            => @url,
          :owner          => "#{video["user_name"]} (via Vimeo)",
          :notes          => "Imported from Vimeo: #{@url}",
          :image_taken    => video["upload_date"],
          :native         => native
        )

        asset.save!
        asset
      end

      #----------------

      def fetch_data
        response = connection.get do |request|
          request.url "video/#{@id}.json"
        end

        response.body
      end


      private

      def image_file(url)
        @image_file ||= open(url)
      end

      def connection
        @connection ||= begin
          Faraday.new('http://vimeo.com/api/v2') do |conn|
            conn.response :json
            conn.adapter Faraday.default_adapter
          end
        end
      end
    end
  end
end
