module ParamHelper
  def admin_request_params(params={})
    params.reverse_merge(use_route: :assethost)
  end

  def api_request_params(params={})
    params.reverse_merge(
      :format       => :json,
      :use_route    => :assethost
    )
  end

  def api_request(method, path, params={})
    headers = { 'Authorization' => Knock::AuthToken.new({payload: { sub: @user.id }}) }
    self.send method, path, {params: params, headers: headers}
  end
end

