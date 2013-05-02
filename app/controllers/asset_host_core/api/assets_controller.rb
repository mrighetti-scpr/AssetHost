module AssetHostCore
  module Api
    class AssetsController < ApplicationController
      before_filter :set_access_control_headers
      before_filter :_authenticate_api_user!
      before_filter :find_asset, only: [:show, :update, :tag]

      respond_to :json


      def index
        if params[:q].present?
          @assets = Asset.visible.search(params[:q],
            :page          => params[:page] ? params[:page].to_i : 1,
            :per_page      => 24,
            :order         => "created_at DESC, @relevance DESC",
            :field_weights => { 
              :title   => 10, 
              :caption => 3 
            }
          )
        else
          @assets = Asset.visible.order("updated_at desc")
            .page(params[:page])
            .per(24)
        end
      
        response.headers['X-Next-Page']       = (@assets.last_page? ? nil : @assets.current_page + 1).to_s
        response.headers['X-Total-Entries']   = @assets.total_count.to_s

        respond_with @assets
      end
    
      #----------

      def show
        respond_with @asset
      end
    
      #----------
    
      def update
        if @asset.update_attributes(params[:asset])
          respond_with @asset
        else
          respond_with @asset.errors.full_messages, :status => :error
        end
      end
    
      #----------

      def tag
        output  = Output.find_by_code!(params[:style])
        ao      = @asset.outputs.where(output_id: output.id).first
        
        tag = { 
          :id           => @asset.id,
          :tag          => @asset.image.tag(params[:style].to_sym),
          :updated_at   => @asset.image_updated_at,
          :owner        => @asset.owner,
          :width        => ao.try(:width),
          :height       => ao.try(:height)
        }

        respond_with tag
      end
    
      #----------
    

      private

      def set_access_control_headers
        response.headers['Access-Control-Allow-Origin'] = request.env['HTTP_ORIGIN'] || "*"
      end

      def find_asset
        @asset = Asset.find(params[:id])
      end
    end
  end
end
