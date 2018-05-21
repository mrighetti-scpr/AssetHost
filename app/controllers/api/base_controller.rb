class Api::BaseController < ActionController::API

  include Knock::Authenticable

  before_action :refresh_bearer_auth_header, if: :bearer_auth_header_present

  respond_to :json

  private
  
  def authenticate_user
    # Knock::AuthToken.new(token: token).entity_for(User)
  rescue Knock.not_found_exception_class, JWT::DecodeError
    render nothing: true, status: 401
  end

  def bearer_auth_header_present
    request.env["HTTP_AUTHORIZATION"] =~ /Bearer/
  end

  def refresh_bearer_auth_header
    authenticate_user
    if current_user
      headers['Authorization'] = Knock::AuthToken.new(payload: { sub: current_user.id }).token
    end
  end
  
  def set_access_control_headers
    response.headers['Access-Control-Allow-Origin'] =
      request.env['HTTP_ORIGIN'] || "*"
  end

end
