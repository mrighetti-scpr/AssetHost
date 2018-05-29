class Api::OutputsController < Api::BaseController
  
  before_action :authenticate_from_token

  before_action :authorize_reads, only: [:index, :show]

  before_action :authorize_writes, only: [:create, :update, :destroy]
  
  before_action :get_output, only: [:show, :update, :destroy]

  def index
    @outputs = Output.all
    render json: @outputs.as_json
  end

  def show
    render json: @output.as_json
  end

  def create
    @output = Output.create(outputs_params)
    render json: @output.as_json
  end

  def update
    @output.assign_attributes(outputs_params)
    @output.save
    render json: @output.as_json
  end

  def destroy
    @output.destroy
    render nothing: true, status: 200
  end

  private

  def authorize_reads
    authorize current_user, "outputs", "read"
  end

  def authorize_writes
    authorize current_user, "outputs", "write"
  end

  def outputs_params
    # 🚨 Remember to add support for is_rich
    params.require(:output).permit(:name, :content_type, :prerender, render_options: [ :name, properties: [ :name, :value ] ] )
  rescue ActionController::ParameterMissing
    {}
  end

  def get_output
    @output = Output.find(params[:id])
  end

end
