module AssetHostCore
  module Loaders
    class Base
      attr_accessor :title, 
        :owner, 
        :description, 
        :url, 
        :created, 
        :file, 
        :source, 
        :id

      #------------------

      def initialize(attributes={})
        @id       = attributes[:id]
        @url      = attributes[:url]
        @source   = self.class::SOURCE
      end
    end
  end
end
