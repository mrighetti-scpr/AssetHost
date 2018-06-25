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
    token = JWT.encode({ sub: @user.id }, Rails.application.config.secret_key_base, "HS256")
    headers = { 'Authorization' => "Bearer #{token}" }
    self.send method, path, {params: params, headers: headers}
  end
end

