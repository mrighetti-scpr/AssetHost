module AssetHostCore
  module Api
    class OutputsController < AssetHostCore::ApplicationController
      before_filter :_authenticate_api_user!
      
      respond_to :json

      def index
        @outputs = Output.all
        respond_with @outputs
      end
    
      #----------
    
      def show
        @output = Output.find_by_code!(params[:id])
        respond_with @output
      end
    end
  end
end
