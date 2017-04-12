class Api::BaseController < ApplicationController
  layout false

  before_action :authenticate_api_user
  respond_to :json


  private

  def set_access_control_headers
    response.headers['Access-Control-Allow-Origin'] =
      request.env['HTTP_ORIGIN'] || "*"
  end


  # For the authentication/authorization checks, if the API is being
  # accessed by AssetHost, then we should give it full write permission.
  # If we add write ability via the API to Outputs or anything else,
  # we should reassess this decision.
  def authenticate_api_user
    return true if current_user
    @api_user = ApiUser.authenticate(params[:auth_token])

    if !@api_user
      render_unauthorized and return false
    end
  end


  def authorize(ability, resource)
    return true if current_user

    if !@api_user.may?(ability, resource)
      render_forbidden and return false
    else
      return true
    end
  end
end
