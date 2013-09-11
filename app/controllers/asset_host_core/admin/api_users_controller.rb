module AssetHostCore
  module Admin
    class ApiUsersController < AssetHostCore::ApplicationController
      before_filter :_authenticate_user!
      before_filter :authorize_admin

      before_filter :get_api_user, only: [
        :show, :edit, :update, :reset_token, :destroy
      ]

      layout 'asset_host_core/full_width'

      def index
        @api_users = ApiUser.page(params[:page]).per(20)
      end


      def edit
      end


      def show
      end


      def new
        @api_user = ApiUser.new
      end


      def create
        @api_user = ApiUser.new(params[:api_user])

        if @api_user.save
          flash[:notice] = "Created API User"
          redirect_to [:a, @api_user]
        else
          render :new
        end
      end


      def update
        if @api_user.update_attributes(params[:api_user])
          flash[:notice] = "Updated API User"
          redirect_to [:a, @api_user]
        else
          render :edit
        end
      end

      def reset_token
        @api_user.generate_api_token!
        flash[:notice] = "Reset API Token"
        redirect_to [:a, @api_user]
      end

      def destroy
        @api_user.destroy
        flash[:notice] = "Destroyed API User"
        redirect_to [:a, @api_user]
      end


      private

      def get_api_user
        @api_user = ApiUser.find(params[:id])
      end
    end
  end
end
