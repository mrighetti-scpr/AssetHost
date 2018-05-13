class Api::SessionsController < ApplicationController

  layout false

  respond_to :json

  def show
    if current_user
      render json: filtered_user(current_user), status: 200
    else
      render nothing: true, status: 404
    end
  end

  def create
    if user = User.authenticate(params[:username], params[:password])
      session[:user_id] = user.id
      render json: filtered_user(user), status: 201
    else
      render nothing: true, status: 401
    end
  end

  def destroy
    @current_user     = nil
    session[:user_id] = nil
    render nothing: true, status: 200
  end

private
  def filtered_user user
    return {
      id:       user.id,
      username: user.username,
      id_admin: user.is_admin
    }
  end
end
