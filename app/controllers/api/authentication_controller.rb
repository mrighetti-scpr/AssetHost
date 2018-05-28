class Api::AuthenticationController < Api::BaseController

  def create
    authenticate_from_credentials
    # token = auth_token
    # headers['Authorization'] = token
    render json: {jwt: auth_token}, status: :created
  end

  def update
    authenticate_from_token
    return deny_access if !current_user
    # token = auth_token
    # headers['Authorization'] = token
    head 201
  end

  def generate
    authenticate_from_token
    return if !current_user || !current_user.can?("users", "write") || !params[:id]
    user  = User.find(params[:id])
    token = Knock::AuthToken.new(payload: { sub: user.id }).token
    render json: {jwt: token}.to_json
  end

end

