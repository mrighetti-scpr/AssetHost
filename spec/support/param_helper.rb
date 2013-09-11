module ParamHelper
  def admin_request_params(params={})
    params.reverse_merge(use_route: :assethost)
  end

  def api_request_params(params={})
    params[:auth_token] ||= @api_user.auth_token

    params.reverse_merge(
      :format       => :json,
      :use_route    => :assethost
    )
  end
end
