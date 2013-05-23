module AssetHostCore
  module Api
    class UtilityController < AssetHostCore::ApplicationController
      before_filter :_authenticate_api_user!
    
      respond_to :json

      # Take a URL and try to find or create an asset out of it
      def as_asset
        if !params[:url]
          render text: "Must provide an asset URL", status: :bad_request
          return
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
          respond_with asset
        
        else
          error = { error: "Unable to find or load an asset at the URL #{params[:url]}" }
          respond_with error, status: :not_found
        end
      end
    end
  end
end
