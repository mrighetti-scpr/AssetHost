class Api::AssetsController < Api::BaseController
  
  before_action :authenticate_user

  before_action :set_access_control_headers

  before_action :get_asset, only: [:show, :update, :tag]

  before_action :get_uploaded_file, only: [:create, :update]


  def index
    if params[:q].present?
      results = Asset.es_search(params[:q], page: params[:page] || 1)
    else
      results = Asset.order("updated_at desc")
                     .page(params[:page])
                     .per(20)
    end

    @assets = results.to_a
    @assets.each {|a| a.request = request }

    response.headers['X-Next-Page']     = (results.last_page? ? nil : results.current_page + 1).to_s
    response.headers['X-Total-Entries'] = results.total_count.to_s

    render json: @assets.to_json
  end


  def show
    render json: @asset.as_json
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
      return
    end
    if @asset.update_attributes(asset_params)
      render json: @asset.as_json
    else
      render json: @asset.errors.full_messages, status: :error
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
        render json: asset.as_json
      else
        head 400
      end
      return
    end

    # if !params[:url]
    head 400 and return if !params[:url]
      # render_bad_request(message: "Must provide an image or an asset URL")
    # end

    # see if we have a loader for this URL
    if asset = AssetHostCore.as_asset(params[:url])
      if params[:note].present?
        asset.notes += "\n#{params[:note]}"
      end

      asset.request     = request
      asset.caption     = params[:caption] if params[:caption].present?
      asset.owner       = params[:owner] if params[:owner].present?
      asset.title       = params[:title] if params[:title].present?

      asset.save
      render json: asset.as_json
    else
      # render_not_found(message: "Unable to find or load an asset at " \
      #                           "the URL #{params[:url]}")
      # render nothing: true, status: 404
      head 404
    end
  rescue URI::InvalidURIError
    # render_bad_request(message: "The URL provided is not valid.")
    head 400
  end


  def tag
    output  = Output.find_by(name: params[:style]) || raise(Mongoid::Errors::DocumentNotFound)
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
    params.require(:asset).permit(:title, :caption, :keywords, :owner, :url, :notes, :creator_id, :image, :image_taken, :native, :image_gravity)
  end

  def upload_params
    params.fetch(:asset, params).permit(:title, :caption, :keywords, :owner, :url, :notes, :creator_id, :image_taken, :native, :image_gravity)
  end

  def get_asset
    @asset         = Asset.find_by(id: params[:id]) || raise(Mongoid::Errors::DocumentNotFound)
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
