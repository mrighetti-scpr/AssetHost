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

        native = YoutubeVideo.create(
          :videoid => video["id"]
        )

        thumbnail = snippet["thumbnails"]["maxres"] ||
                    snippet["thumbnails"]["high"]

        @image_url = thumbnail["url"]

        byebug

        asset = Asset.new(
          :file           => image_file,
          :title          => snippet["title"],
          :caption        => snippet["description"],
          :url            => @url,
          :owner          => "#{snippet["channelTitle"]} (via YouTube)",
          :notes          => "Imported from YouTube: #{@url}",
          :image_taken    => snippet["publishedAt"],
          :image_content_type => image_file.content_type,
          :native         => native
        )

        asset.save!

        # We won't pass an argument to this because it may be a Tempfile
        # (which takes an optional argument) or a File
        # (which doesn't take any args)
        image_file.close

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

      def image_file
        @image_file ||= open(@image_url)
      end

      # def image_file
      #   @image_file ||= begin
      #     tempfile = Tempfile.new('ah-youtube', encoding: "ascii-8bit")
      #     open(@image_url) { |f| tempfile.write(f.read) }
      #     tempfile.rewind

      #     @url.match(/ah-noTrim/) ? tempfile : Paperclip::Trimmer.make(tempfile)
      #   end
      # end

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
