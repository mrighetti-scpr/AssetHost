module AssetHostCore
  module Loaders
    class Base
      attr_accessor :title, :owner, :description, :url, :created, :file, :source, :id

      class << self
        def self.valid_url?(url)
          parse_url(url).present?
        end
      end


      #-------------------

    end
  end
end
