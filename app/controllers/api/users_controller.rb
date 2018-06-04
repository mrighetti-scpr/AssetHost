class Api::UsersController < Api::BaseController
  before_action :authenticate_from_token

  before_action :authorize_reads, only: [:index, :show]

  before_action :authorize_writes, only: [:create, :update, :destroy]
  
  before_action :get_user, only: [:show, :update, :destroy]

  def index
    @users = User.all
    render json: @users.as_json
  end

  def show
    render json: @user.as_json
  end

  def create
    @user = User.create(user_params)
    render json: @user.as_json
  end

  def update
    @user.assign_attributes(user_params)
    @user.save
    render json: @user.as_json
  end

  def destroy
    @user.destroy
    render nothing: true, status: 200
  end

  private

  def authorize_reads
    authorize current_user, "users", "read"
  end

  def authorize_writes
    authorize current_user, "users", "write"
  end

  def user_params
    params.require(:user).permit(:username, :password, :is_admin, :is_active, :permissions)
  end

  def get_user
    @user = User.find(params[:id])
  end

end
