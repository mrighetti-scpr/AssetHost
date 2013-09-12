module AssetHostCore
  module Admin
    class AssetsController < AssetHostCore::ApplicationController
      before_filter :_authenticate_user!
      before_filter :load_asset, only: [:show, :update, :replace, :destroy]
      skip_before_filter :verify_authenticity_token, only: [:upload, :replace]

      #----------

      def index
        @assets = Asset.visible.order("updated_at desc")
          .page(params[:page])
          .per(24)
      end

      #----------

      def search
        @query = params[:q]

        @assets = Asset.visible.search(@query,
          :page          => params[:page] ? params[:page].to_i : 1,
          :per_page      => 24,
          :order         => "created_at DESC, @relevance DESC",
          :field_weights => {
            :title   => 10,
            :caption => 5
          }
        )

        render :index
      end

      #----------

      def upload
        file = params[:file]

        # FIXME: Put in place to keep Firefox 7 happy
        if !file.original_filename
          file.original_filename = "upload.jpg"
        end

        asset = Asset.new(image: file)

        if asset.save
          render json: asset.as_json
        else
          render text: 'ERROR'
        end
      end

      #----------

      def metadata
        @assets = Asset.where(id: params[:ids].split(','))
      end

      #----------

      def update_metadata
        params[:assets].each do |id, attributes|
          asset = Asset.find(id)
          asset.update_attributes(attributes)
        end

        redirect_to a_assets_path
      end

      #----------

      def show
        # Use "visible" here because we are choosing next/prev based on the
        # index listing. Hard-coding the order here (ID) because the
        # AssetHostBrowserUI uses ID if no ORDER option is passed in, which
        # it currently isn't, so the grid is ordered by ID.
        @assets   = AssetHostCore::Asset.visible.order('id desc')
        @prev     = @assets.where('id > ?', @asset.id).last
        @next     = @assets.where('id < ?', @asset.id).first
      end

      #----------

      def update
        if @asset.update_attributes(params[:asset])
          flash[:notice] = "Successfully updated asset."
          redirect_to a_asset_path(@asset)
        else
          flash[:notice] = @asset.errors.full_messages.join("<br/>")
          render :action => :edit
        end
      end

      #----------

      def replace
        file = params[:file]

        if !file
          render :text => 'ERROR' and return
        end

        # FIXME: Put in place to keep Firefox 7 happy
        if !file.original_filename
          file.original_filename = "upload.jpg"
        end

        # tell paperclip to replace our image
        @asset.image = file

        if @asset.save
          render json: @asset.as_json
        else
          puts "Error: #{@asset.errors.to_s}"
          render :text => 'ERROR'
        end
      end

      #----------

      def destroy
        if @asset.destroy
          flash[:notice] = "Deleted asset #{@asset.title}."
          redirect_to a_assets_path
        else
          flash[:error] = "Unable to delete asset."
          redirect_to a_asset_path(@asset)
        end
      end


      #----------

      protected

      def load_asset
        @asset = Asset.find(params[:id])
      end
    end
  end
end
