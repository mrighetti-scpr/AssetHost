module AssetHostCore
  module Admin
    class OutputsController < AssetHostCore::ApplicationController
      before_filter :_authenticate_user!
      before_filter :authorize_admin
      before_filter :get_output, except: [:index, :new, :create]
      layout 'asset_host_core/full_width'


      def index
        @outputs = Output.all
      end


      def update
        if @output.update_attributes(params[:output])
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
        @output = Output.new(params[:output])

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

      def get_output
        @output = Output.find(params[:id])
      end
    end
  end
end
