class Api::BaseController < ApplicationController

  include Knock::Authenticable

  before_action :refresh_bearer_auth_header, if: :bearer_auth_header_present

  layout false

  # before_action :authenticate_api_user
  respond_to :json

  private
  
  def authenticate_user
    Knock::AuthToken.new(token: token).entity_for(User)
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


  # For the authentication/authorization checks, if the API is being
  # accessed by AssetHost, then we should give it full write permission.
  # If we add write ability via the API to Outputs or anything else,
  # we should reassess this decision.
  # def authenticate_api_user
  #   return true if current_user
  #   @api_user = ApiUser.authenticate(params[:auth_token])

  #   if !@api_user
  #     render_unauthorized and return false
  #   end
  # end


  # def authorize(ability, resource)
  #   return true if current_user

  #   if !@api_user.may?(ability, resource)
  #     render_forbidden and return false
  #   else
  #     return true
  #   end
  # end
end
