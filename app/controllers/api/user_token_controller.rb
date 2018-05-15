class Api::UserTokenController < Knock::AuthTokenController
  def auth_params
    params.require(:user_token).permit :email, :password
  end
  def create
    json = super
    if json
      headers['Authorization'] = JSON.parse(json)["jwt"]
    end
  end
end
