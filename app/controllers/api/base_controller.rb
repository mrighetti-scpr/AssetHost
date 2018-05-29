class Api::BaseController < ActionController::API

  rescue_from Knock.not_found_exception_class_name, JWT::DecodeError, Mongoid::Errors::InvalidFind, with: :deny_access

  rescue_from AuthorizationHelper::UnauthorizedError, with: :forbidden

  respond_to :json

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

  include AuthenticationHelper
  include AuthorizationHelper

end
