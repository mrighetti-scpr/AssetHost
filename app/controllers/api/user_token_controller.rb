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
  def update
    authenticate_user
    return if !current_user
    headers['Authorization'] = Knock::AuthToken.new(payload: { sub: current_user.id }).token
  end
end

