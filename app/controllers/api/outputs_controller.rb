class Api::OutputsController < Api::BaseController
  before_action :authenticate_user
  
  before_action :get_output, only: [:show, :update, :destroy]

  def index
    @outputs = Output.all
    respond_with @outputs
  end

  def show
    respond_with @output
  end

  def create
    @output = Output.create(outputs_params)
    respond_with @output
  end

  def update
    @output.assign_attributes(outputs_params)
    @output.save
    respond_with @output
  end

  def destroy
    @output.destroy
    render nothing: true, status: 200
  end

  private

  def outputs_params
    # 🚨 Remember to add support for is_rich
    params.require(:output).permit(:name, :render_options, :content_type, :prerender)
  end

  def get_output
    @output = Output.find(params[:id])
  end

end
