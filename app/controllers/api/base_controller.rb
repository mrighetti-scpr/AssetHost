class Api::BaseController < ActionController::API

  rescue_from Knock.not_found_exception_class_name, JWT::DecodeError, Mongoid::Errors::InvalidFind, with: :deny_access

  # after_action :add_authorization_header

  respond_to :json

  def deny_access
    head 401
  end

  def not_found
    head :not_found
  end

  private

  include AuthenticationHelper

end
