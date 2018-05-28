class Api::TokenController < Api::BaseController

  before_action :authenticate_user

  def generate
    return if !current_user || !current_user.can?("users", "write") || !params[:id]
    user  = User.find(params[:id])
    token = Knock::AuthToken.new(payload: { sub: user.id }).token
    render json: {jwt: token}.to_json
  end

end
