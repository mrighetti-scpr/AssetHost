class SessionsController < ApplicationController
  # respond_to :html

  def new
    redirect_to assets_path if current_user
  end

  def create
    if user = User.authenticate(params[:username], params[:password])
      session[:user_id] = user.id
      redirect_to session[:return_to] || assets_path, notice: "Logged in."
      session[:return_to] = nil
    else
      flash.now[:error] = "Invalid login information."
      render :new
    end
  end

  def destroy
    @current_user = nil
    session[:user_id] = nil
    redirect_to login_path, notice: "Logged Out."
  end
end
