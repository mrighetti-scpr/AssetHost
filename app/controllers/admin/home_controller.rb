class Admin::HomeController < Admin::BaseController
  def chooser
    @assets = Asset.order("updated_at desc")
      .page(params[:page])
      .per(24)

    render layout: 'minimal'
  end
end
