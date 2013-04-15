module AssetHostCore
  module Loaders
    MODULES = [
      "Asset",
      "Brightcove",
      "Flickr",
      "URL"
    ]

    class << self  
      def load(url)
        asset = nil

        MODULES.each do |klass| 
          if loader = klass.constantize.valid?(url)
            asset = loader.load
            break
          end
        end
        
        return asset
      end
      

      def classes
        puts "Classes: " + @@discovered.to_s
      end
    end
  end
end
