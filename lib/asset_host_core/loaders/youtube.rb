module AssetHostCore
  module Loaders
    class YouTube < Base
      SOURCE = "YouTube"

      #----------------

      def self.build_from_url(url)
        return nil if AssetHostCore.config.google_api_key.blank?
        
        url.match(/youtube\.com\/watch\?.*v=(?<id>[\w-]+)/i) do |m|
          self.new(url: url, id: m[:id])
        end
      end

      #----------------

      def load
        data = fetch_data

        video = data["items"][0]
        return nil if !video

        snippet = video["snippet"]
        return nil if !snippet

        native = AssetHostCore::YoutubeVideo.create(
          :videoid => video["id"]
        )

        asset = AssetHostCore::Asset.new(
          :image          => image_file(snippet["thumbnails"]["high"]["url"]),
          :title          => snippet["title"],
          :caption        => snippet["description"],
          :url            => @url,
          :owner          => "#{snippet["channelTitle"]} (via YouTube)",
          :notes          => "Imported from YouTube: #{@url}",
          :image_taken    => snippet["publishedAt"],
          :native         => native
        )

        asset.save!
        asset
      end

      #----------------

      def fetch_data
        response = client.execute!(
          :api_method => youtube.videos.list,
          :parameters => {
            :id   => @id,
            :part => 'id,snippet,contentDetails,player'
          }
        )

        JSON.parse(response.body)
      end

      #----------------

      private

      def image_file(url)
        @image_file ||= begin
          response = open(url)

          tempfile = Tempfile.new('ah-youtube', encoding: "ascii-8bit")
          tempfile.write response.read

          @url.match(/ah-noTrim/) ? tempfile : Paperclip::Trimmer.make(tempfile)
        end
      end

      def client
        @client ||= Google::APIClient.new(
          :key              => AssetHostCore.config.google_api_key,
          :authorization    => nil
        )
      end

      def youtube
        @youtube ||= client.discovered_api('youtube', 'v3')
      end
    end
  end
end
