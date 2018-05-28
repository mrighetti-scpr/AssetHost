class Api::UserTokenController < Knock::AuthTokenController

  def auth_params
    params.require(:user_token).permit :username, :identification, :password
  end

  def create
    json = super
    return if !json
    headers['Authorization'] = JSON.parse(json)["jwt"]
  end

  def update
    authenticate_user
    return if !current_user
    headers['Authorization'] = Knock::AuthToken.new({ payload: current_user.to_token_payload }).token
  end

end

