class Admin::BaseController < ApplicationController
  layout 'application'

  # HACK
  before_action :_authenticate_user!

  helper_method :_current_user
  helper_method :_sign_out_path

  def _authenticate_user!
    # instance_eval &AssetHostCore::Config.authentication_method
    if !current_user
      session[:return_to] = request.fullpath
      redirect_to Rails.application.routes.url_helpers.login_path
      false
    end
  end


  def _current_user
    # instance_eval &AssetHostCore::Config.current_user_method
    begin
      @current_user ||= User.where(can_login: true).find(session[:user_id])
    rescue ActiveRecord::RecordNotFound
      session[:user_id]   = nil
      @current_user       = nil
    end
  end


  def _sign_out_path
    #HACK
    # instance_eval &AssetHostCore::Config.sign_out_path
    Rails.application.routes.url_helpers.logout_path
  end


  private

  def authorize_admin
    unless current_user.try(:is_admin?)
      flash[:error] = "You must be a superuser to do that."
      redirect_to a_root_path and return false
    end
  end
end
