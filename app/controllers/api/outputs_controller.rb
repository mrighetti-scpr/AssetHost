class Api::OutputsController < Api::BaseController
  before_action :authenticate_user
  
  before_filter :get_output, only: [:show]

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

  def destroy
    @output.destroy
    render nothing: true, status: 200
  end

  private

  def outputs_params
    params.require(:output).permit(:code, :size, :extension, :prerender, :is_rich)
  end

  def get_output
    @output = Output.find(params[:id])
  end

end
