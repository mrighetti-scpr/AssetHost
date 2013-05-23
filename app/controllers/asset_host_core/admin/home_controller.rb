module AssetHostCore
  module Admin
    class HomeController < AssetHostCore::ApplicationController
      before_filter :_authenticate_user!

      def chooser
        @assets = AssetHostCore::Asset.order("updated_at desc")
          .page(params[:page])
          .per(24)
        
        render layout: 'asset_host_core/minimal'
      end
    end
  end
end
