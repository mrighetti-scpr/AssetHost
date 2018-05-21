class Api::OutputsController < Api::BaseController
  before_action :authenticate_user
  
  before_action :get_output, only: [:show, :destroy]

  def index
    @outputs = OutputX.all
    respond_with @outputs
  end

  def show
    respond_with @output
  end

  def create
    @output = OutputX.create(outputs_params)
    respond_with @output
  end

  def destroy
    @output.destroy
    render nothing: true, status: 200
  end

  private

  def outputs_params
    params.require(:output).permit(:name, :render_options, :extension, :prerender)
  end

  def get_output
    @output = OutputX.find(params[:id])
  end

end
