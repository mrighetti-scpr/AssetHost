class Admin::AssetsController < Admin::BaseController
  before_action :get_asset, only: [:show, :update, :replace, :destroy]
  skip_before_action :verify_authenticity_token, only: [:upload, :replace]

  #----------

  def index
    @assets = Asset.visible.order("updated_at desc")
      .page(params[:page])
      .per(24)
  end

  #----------

  def search
    @query = params[:q]
    @assets = Asset.es_search(@query,page:params[:page]||1)

    render :index
  end

  #----------

  def upload
    file = request.env['rack.input']
    file.class.class_eval { attr_accessor :original_filename, :content_type }
    file.original_filename = request.headers['HTTP_X_FILE_NAME']
    file.content_type      = request.headers['HTTP_CONTENT_TYPE']

    # asset = Asset.new(image: file, image_file_name: request.headers['HTTP_X_FILE_NAME'], image_content_type: request.headers['HTTP_CONTENT_TYPE'])
    asset = Asset.new(image: file, image_file_name: request.headers['HTTP_X_FILE_NAME'], image_content_type: request.headers['HTTP_CONTENT_TYPE'])

    if asset.save
      render json: asset.as_json
    else
      render plain: 'ERROR'
    end
  rescue => e
    byebug
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
    @assets   = Asset.visible.order('id desc')
    @prev     = @assets.where('id > ?', @asset.id).last
    @next     = @assets.where('id < ?', @asset.id).first
  end

  #----------

  def update
    if @asset.update_attributes(asset_params)
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
      render plain: 'ERROR'
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

  def asset_params
    params.require(:asset).permit(:title, :caption, :owner, :url, :notes, :creator_id, :image, :image_taken, :native, :image_gravity)
  end

  def get_asset
    @asset = Asset.find(params[:id])
  end
end