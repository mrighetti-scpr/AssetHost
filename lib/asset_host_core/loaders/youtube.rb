module AssetHostCore
  module Loaders
    class YouTube < Base
      SOURCE = "YouTube"

      def self.build_from_url(url)
        return nil if Rails.application.secrets.google_api_key.blank?

        url.match(/youtube\.com\/watch\?.*v=(?<id>[\w-]+)/i) do |m|
          self.new(url: url, id: m[:id])
        end
      end

      def load
        video = Yt::Video.new id: @id

        return if !video

        snippet = video.snippet
        return if !snippet

        native = {
          "type"       => "youtube",
          "content_id" => video.id
        }

        thumbnail = snippet.thumbnails["high"] ||
                    snippet.thumbnails["default"]

        @image_url = thumbnail["url"]

        asset = Asset.new(
          :file           => image_file,
          :title          => snippet.title,
          :caption        => snippet.description,
          :url            => @url,
          :owner          => "#{snippet.channel_title} (via YouTube)",
          :notes          => "Imported from YouTube: #{@url}",
          :image_taken    => snippet.published_at,
          :image_content_type => image_file.content_type,
          :native         => native,
          :keywords       => snippet.tags.join(", ")
        )

        asset.save!

        # We won't pass an argument to this because it may be a Tempfile
        # (which takes an optional argument) or a File
        # (which doesn't take any args)
        image_file.close

        asset
      end

      private

      def image_file
        @image_file ||= open(@image_url)
      end

    end
  end
end
