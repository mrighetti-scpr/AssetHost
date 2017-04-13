class Api::AssetsController < Api::BaseController
  before_action :set_access_control_headers

  before_action -> { authorize(:read) }, only: [:index, :show, :tag]
  before_action -> { authorize(:write) }, only: [:update, :create]

  before_action :get_asset, only: [:show, :update, :tag]


  def index
    if params[:q].present?
      @assets = Asset.es_search(params[:q],page:params[:page]||1)
    else
      @assets = Asset.visible.order("updated_at desc")
        .page(params[:page])
        .per(24)
    end

    response.headers['X-Next-Page']       = (@assets.last_page? ? nil : @assets.current_page + 1).to_s
    response.headers['X-Total-Entries']   = @assets.total_count.to_s

    respond_with @assets.to_json
  end


  def show
    respond_with @asset
  end


  def update
    if @asset.update_attributes(asset_params)
      respond_with @asset
    else
      respond_with @asset.errors.full_messages, :status => :error
    end
  end


  def create
    if !params[:url]
      render_bad_request(message: "Must provide an asset URL")
      return false
    end

    # see if we have a loader for this URL
    if asset = AssetHostCore.as_asset(params[:url])
      if params[:note].present?
        asset.notes += "\n#{params[:note]}"
      end

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

  def authorize(ability)
    super ability, "Asset"
  end

  def get_asset
    @asset = Asset.find_by_id(params[:id])

    if !@asset
      render_not_found and return false
    end
  end
end
