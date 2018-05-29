class Api::AuthenticationController < Api::BaseController

  def show
    return head(404) unless params[:ticket]
    conn = Faraday.new(url: ENV["ASSETHOST_CAS_SERVICE_URL"])
    current_port = ((request.port === 80) || (request.port === 443)) ? "" : ":#{request.port}"
    current_host = "#{request.protocol}#{request.host}#{port}"
    resp = conn.get '/serviceValidate', { ticket: params[:ticket], service: "#{current_host}/api/authenticate" } 
    parser = Nori.new(parser: :rexml)
    xml    = parser.parse(resp.body)
    username = xml.dig("cas:serviceResponse", "cas:authenticationSuccess", "cas:user")
    return head(401) unless username
    @entity = User.find_or_create_by(username: username, password: SecureRandom.base64(12))
    redirect_to "#{current_host}/login/?token=#{auth_token}"
  end

  def create
    authenticate_from_credentials
    render json: {jwt: auth_token}, status: :created
  rescue Mongoid::Errors::DocumentNotFound
    head 422
  end

  def update
    authenticate_from_token
    return deny_access if !current_user
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

