module AuthenticationHelper
  class AuthenticationError < StandardError
  end
  def bearer_auth_header_present
    request.env["HTTP_AUTHORIZATION"] =~ /Bearer/
  end

  def add_authorization_header
    if auth_token
      headers['Authorization'] = "Bearer #{auth_token}"
    end
  end

  def auth_token
    payload = entity.to_token_payload
    payload["exp"] = 30.days.from_now.to_i
    @auth_token = JWT.encode(payload, Rails.application.config.secret_key_base, "HS256")
  end

  def authenticate_from_credentials
    unless entity.present? && entity.authenticate(auth_params[:password])
      raise AuthenticationError
    end
  end

  def current_user
    @current_entity
  end

  def response_token
    @response_token
  end

  def authenticate_from_token
    raise AuthenticationError if !request_token
    decoded = JWT.decode request_token, Rails.application.config.secret_key_base, true
    payload = decoded[0]
    @current_entity = User.find(payload["sub"])
  rescue JWT::ExpiredSignature, JWT::DecodeError, Mongoid::Errors::DocumentNotFound, Mongoid::Errors::InvalidFind
    raise AuthenticationError
  end

  def entity
    @entity ||= User.find_by username: auth_params[:username]
  end

  def auth_params
    {username: params[:username], password: params[:password]}
  end

  def request_token
    params[:token] || params["jwt"] || token_from_request_headers
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
