class ApplicationController < ActionController::Base
  protect_from_forgery

  layout 'asset_host_core/application'

  def current_user
    begin
      @current_user ||= User.find(session[:user_id])
    rescue ActiveRecord::RecordNotFound
      session[:user_id]   = nil
      @current_user       = nil
    end
  end

  helper_method :current_user
end
