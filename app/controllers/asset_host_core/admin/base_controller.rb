module AssetHostCore
  module Admin
    class BaseController < ApplicationController
      layout 'asset_host_core/application'

      before_filter :_authenticate_user!

      helper_method :_current_user
      helper_method :_sign_out_path

      def _authenticate_user!
        instance_eval &AssetHostCore::Config.authentication_method
      end


      def _current_user
        instance_eval &AssetHostCore::Config.current_user_method
      end


      def _sign_out_path
        instance_eval &AssetHostCore::Config.sign_out_path
      end


      private

      def authorize_admin
        unless current_user.is_admin?
          flash[:error] = "You must be a superuser to do that."
          redirect_to assethost.a_root_path and return false
        end
      end
    end
  end
end
