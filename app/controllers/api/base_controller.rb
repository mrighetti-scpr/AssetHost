class Api::BaseController < ActionController::API

  rescue_from Knock.not_found_exception_class_name, JWT::DecodeError, Mongoid::Errors::InvalidFind, with: :deny_access

  rescue_from AuthorizationHelper::UnauthorizedError, with: :forbidden

  rescue_from Mongoid::Errors::Validations, with: :validation_error 

  private

  def deny_access
    head 401
  end

  def not_found
    head :not_found
  end

  def forbidden
    head 403
  end

  def validation_error err
    render json: {error: {message: err.summary}}, status: 422
  end

  include AuthenticationHelper
  include AuthorizationHelper

end
