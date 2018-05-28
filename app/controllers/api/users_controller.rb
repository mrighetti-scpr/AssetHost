class Api::UsersController < Api::BaseController
  before_action :authenticate_user
  
  before_action :get_user, only: [:show, :update, :destroy]

  def index
    @users = User.all
    respond_with @users
  end

  def show
    respond_with @user
  end

  def create
    @user = User.create(user_params)
    respond_with @user
  end

  def update
    @user.assign_attributes(user_params)
    @user.save
    respond_with @user
  end

  def destroy
    @user.destroy
    render nothing: true, status: 200
  end

  private

  def user_params
    params.require(:user).permit(:username, :password, :is_admin, :is_active, :permissions)
  end

  def get_user
    @user = User.find(params[:id])
  end

end
