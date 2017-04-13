class Admin::ApiUsersController < Admin::BaseController
  layout 'full_width'

  before_action :authorize_admin
  before_action :get_api_user, only: [
    :show, :edit, :update, :reset_token, :destroy
  ]

  def index
    @api_users = ApiUser.page(params[:page]).per(20)
  end


  def edit
  end


  def show
  end


  def new
    @api_user = ApiUser.new
  end


  def create
    @api_user = ApiUser.new(api_user_params)

    if @api_user.save
      flash[:notice] = "Created API User"
      redirect_to [:api_users]
    else
      render :new
    end
  end


  def update
    if @api_user.update_attributes(api_user_params)
      flash[:notice] = "Updated API User"
      redirect_to [:api_users]
    else
      render :edit
    end
  end

  def reset_token
    @api_user.generate_auth_token!
    flash[:notice] = "Reset API Token for #{@api_user.name}"
    redirect_to [:api_users]
  end

  def destroy
    @api_user.destroy
    flash[:notice] = "Destroyed API User"
    redirect_to [:api_users]
  end


  private

  def api_user_params
    params.require(:api_user).permit(:name, :email, :is_active, :permission_ids)
  end

  def get_api_user
    @api_user = ApiUser.find(params[:id])
  end
end