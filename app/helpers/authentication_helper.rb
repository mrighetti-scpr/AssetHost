module AuthenticationHelper
  def bearer_auth_header_present
    request.env["HTTP_AUTHORIZATION"] =~ /Bearer/
  end

  def add_authorization_header
    if auth_token
      headers['Authorization'] = "Bearer #{auth_token}"
    end
  end

  def auth_token
    @auth_token = Knock::AuthToken.new(payload: entity.to_token_payload).token
  end

  def authenticate_from_credentials
    unless entity.present? && entity.authenticate(auth_params[:password])
      raise Knock.not_found_exception_class
    end
  end

  def current_user
    @current_entity
  end

  def response_token
    @response_token
  end

  def authenticate_from_token
    @current_entity = Knock::AuthToken.new(token: request_token).entity_for(User)
  end

  def entity
    @entity ||= User.find_by username: auth_params[:username]
  end

  def auth_params
    # params.require(:user_token).permit :username, :identification, :password
    {username: params[:username], password: params[:password]}
  end

  def request_token
    params[:token] || token_from_request_headers
  end

  def token_from_request_headers
    unless request.headers['Authorization'].nil?
      request.headers['Authorization'].split.last
    end
  end

  def bearer_auth_header_present?
    request.env["HTTP_AUTHORIZATION"] =~ /Bearer/
  end
end
