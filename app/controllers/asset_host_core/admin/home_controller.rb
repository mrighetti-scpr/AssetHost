module AssetHostCore
  module Admin
    class HomeController < BaseController
      def chooser
        @assets = AssetHostCore::Asset.order("updated_at desc")
          .page(params[:page])
          .per(24)
        
        render layout: 'asset_host_core/minimal'
      end
    end
  end
end
