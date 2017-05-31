class Admin::HomeController < Admin::BaseController
  def chooser
    @assets = Asset.order("updated_at desc")
      .page(params[:page])
      .per(24)

    @assets.map {|a| a.request = request}

    render layout: 'minimal'
  end
end
