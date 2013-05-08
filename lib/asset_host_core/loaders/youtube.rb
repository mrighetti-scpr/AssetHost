module AssetHostCore
  module Loaders
    class YouTube < Base
      SOURCE = "YouTube"

      #----------------

      def self.try_url(url)
        url.match(/youtube\.com\/watch\?.*v=(?<id>\w+)/i) do |m|
          self.new(url: url, id: m[:id])
        end
      end

      #----------------

      def fetch_data
        connection.get do |request|
          request.url "/feeds/api/videos/#{@id}"
          request.params['v'] = 2
        end
      end


      private

      def connection
        @connection ||= begin
          Faraday.new('http://gdata.youtube.com') do |conn|
            conn.response :xml
            conn.adapter Faraday.default_adapter
          end
        end
      end
    end
  end
end
