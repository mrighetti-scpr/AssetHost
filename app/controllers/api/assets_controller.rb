class Api::AssetsController < Api::BaseController
  before_action :set_access_control_headers

  before_action -> { authorize(:read) }, only: [:index, :show, :tag]
  before_action -> { authorize(:write) }, only: [:update, :create]

  before_action :get_asset, only: [:show, :update, :tag]

  before_action :get_uploaded_file, only: [:create, :update]


  def index
    if params[:q].present?
      @assets = Asset.es_search(params[:q],page:params[:page]||1)
    else
      @assets = Asset.visible.order("updated_at desc")
        .page(params[:page])
        .per(20)
    end

    @assets.map {|a| a.request = request}

    response.headers['X-Next-Page']       = (@assets.last_page? ? nil : @assets.current_page + 1).to_s
    response.headers['X-Total-Entries']   = @assets.total_count.to_s

    respond_with @assets.to_json
  end


  def show
    respond_with @asset
  end


  def update
    if @file
      @asset.file               = @file
      @asset.image_file_name    = @file.original_filename
      @asset.image_content_type = @file.content_type
      @asset.assign_attributes(upload_params)
      if @asset.save
        @asset.request = request
        render json: @asset.as_json
      else
        render nothing: true, status: 400
      end
      return false
    end

    if @asset.update_attributes(asset_params)
      respond_with @asset
    else
      respond_with @asset.errors.full_messages, :status => :error
    end

  end

  def create
    if @file
      asset = Asset.new(upload_params)
      asset.file               = @file
      asset.image_file_name    = @file.original_filename
      asset.image_content_type = @file.content_type
      if asset.save
        asset.request = request
        respond_with asset, location: asset_path(asset)
      else
        render nothing: true, status: 400
      end
      return false
    end

    if !params[:url]
      render_bad_request(message: "Must provide an image or an asset URL")
      return false
    end

    # see if we have a loader for this URL
    if asset = AssetHostCore.as_asset(params[:url])
      if params[:note].present?
        asset.notes += "\n#{params[:note]}"
      end

      asset.request     = request
      asset.is_hidden   = params[:hidden].present?
      asset.caption     = params[:caption] if params[:caption].present?
      asset.owner       = params[:owner] if params[:owner].present?
      asset.title       = params[:title] if params[:title].present?

      asset.save
      respond_with asset, location: asset_path(asset)

    else
      render_not_found(message: "Unable to find or load an asset at " \
                                "the URL #{params[:url]}")
      return false
    end
  rescue URI::InvalidURIError
    render_bad_request(message: "The URL provided is not valid.")
    return false 
  end


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


  private

  def asset_params
    params.require(:asset).permit(:title, :caption, :owner, :url, :notes, :creator_id, :image, :image_taken, :native, :image_gravity)
  end

  def upload_params
    params.fetch(:asset, params).permit(:title, :caption, :owner, :url, :notes, :creator_id, :image_taken, :native, :image_gravity)
  end

  def authorize(ability)
    super ability, "Asset"
  end

  def get_asset
    @asset         = Asset.find_by_id!(params[:id])
    @asset.request = request
  end

  def get_uploaded_file
    if params[:image].is_a?(ActionDispatch::Http::UploadedFile)
      @file = params[:image]
    elsif request.headers['HTTP_X_FILE_UPLOAD'] && request.env['rack.input']
      @file = ActionDispatch::Http::UploadedFile.new({tempfile: request.env['rack.input']})
    end
    return nil if @file.nil?
    @file.original_filename = request.headers['HTTP_X_FILE_NAME']     || @file.original_filename || "untitled.jpg"
    @file.content_type      = (params[:content_type]                  || # custom param overrides
                              request.headers['HTTP_X_CONTENT_TYPE']  || # custom header overrides
                              @file.content_type                      || # assumed content type overrides
                              request.headers['HTTP_CONTENT_TYPE']    || # request content type
                              Rack::Mime::MIME_TYPES[".#{@file.original_filename.split('.').last}"]) # fallback to file extension
                              .split(/\,\s*/).select{|c| c.match("image/")}.first
  end

end
