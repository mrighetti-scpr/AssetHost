class Api::OutputsController < Api::BaseController
  before_filter -> { authorize(:read) }, only: [:index, :show]
  before_filter :get_output, only: [:show]


  def index
    @outputs = Output.all
    respond_with @outputs
  end

  def show
    respond_with @output
  end


  private

  def authorize(ability)
    super ability, "Output"
  end

  def get_output
    @output = Output.find_by_code(params[:id])

    if !@output
      render_not_found and return false
    end
  end
end
