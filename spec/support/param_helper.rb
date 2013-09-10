module ParamHelper
  DEFAULTS = {
    :format       => :json,
    :use_route    => :assethost
  }

  def request_params(params={})
    params.merge DEFAULTS
  end
end
