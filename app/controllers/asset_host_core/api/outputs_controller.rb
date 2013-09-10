module AssetHostCore
  module Api
    class OutputsController < AssetHostCore::ApplicationController
      before_filter :authenticate_api_user
      before_filter -> { authorize(:read) }, only: [:index, :show]
      before_filter :get_output, only: [:show]

      respond_to :json

      def index
        @outputs = Output.all
        respond_with @outputs
      end

      #----------

      def show
        respond_with @output
      end


      private

      def authorize(ability)
        if !@api_user.may?(ability, "AssetHostCore::Output")
          render_forbidden and return false
        end
      end

      def get_output
        @output = Output.find_by_code(params[:id])

        if !@output
          render_not_found and return false
        end
      end
    end
  end
end
