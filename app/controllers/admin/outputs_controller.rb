class Admin::OutputsController < Admin::BaseController
  layout 'full_width'

  before_action :authorize_admin
  before_action :get_output, except: [:index, :new, :create]


  def index
    @outputs = Output.all
  end


  def update
    if @output.update_attributes(outputs_params)
      flash[:notice] = "Updated Output."
      redirect_to a_outputs_path
    else
      render :edit
    end
  end


  def new
    @output = Output.new
  end


  def create
    @output = Output.new(outputs_params)

    if @output.save
      flash[:notice] = "Created Output."
      redirect_to a_outputs_path
    else
      render :new
    end
  end


  def destroy
    @output.destroy
    flash[:notice] = "Destroyed Output."
    redirect_to a_outputs_path
  end

  private

  def outputs_params
    params.require(:output).permit(:code, :size, :extension, :prerender, :is_rich)
  end

  def get_output
    @output = Output.find(params[:id])
  end
end
