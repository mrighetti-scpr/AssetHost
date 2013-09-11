module ParamHelper
  DEFAULTS = {
    :format       => :json,
    :use_route    => :assethost
  }

  def request_params(params={})
    params[:auth_token] ||= @api_user.auth_token
    params.reverse_merge(DEFAULTS)
  end
end
