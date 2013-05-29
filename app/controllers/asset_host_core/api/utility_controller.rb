module AssetHostCore
  module Api
    class UtilityController < AssetHostCore::ApplicationController
      before_filter :_authenticate_api_user!
    
      respond_to :json

      # Take a URL and try to find or create an asset out of it
      def as_asset
        if !params[:url]
          render_bad_request(message: "Must provide an asset URL") and return
        end
      
        # see if we have a loader for this URL
        if asset = AssetHostCore.as_asset(params[:url])
          if params[:note].present?
            asset.notes += "\n#{params[:note]}"
          end
        
          asset.is_hidden   = true if params[:hidden].present?
          asset.caption     = params[:caption] if params[:caption].present?
          asset.owner       = params[:owner] if params[:owner].present?
          asset.title       = params[:title] if params[:title].present?
          
          asset.save
          respond_with asset, location: a_asset_path(asset)
        
        else
          render_not_found(message: "Unable to find or load an asset at the URL #{params[:url]}") and return
        end
      end
    end
  end
end
