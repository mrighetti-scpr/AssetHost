module AssetHostCore
  class ApplicationController < ::ApplicationController
    helper_method :_current_user
    helper_method :_sign_out_path

    def _authenticate_user!
      instance_eval &AssetHostCore::Config.authentication_method
    end

    #----------

    def _current_user
      instance_eval &AssetHostCore::Config.current_user_method
    end

    #----------

    def _sign_out_path
      instance_eval &AssetHostCore::Config.sign_out_path
    end

    #----------

    private

    def authenticate_api_user
      @api_user = ApiUser.authenticate(params[:auth_token])

      if !@api_user
        render_unauthorized and return false
      end
    end

    def authorize_admin
      unless current_user.is_admin?
        redirect_to assethost.root_path and return false
      end
    end

    def authorize(ability, resource)
      if !@api_user.may?(ability, resource)
        render_forbidden and return false
      end
    end


    def render_not_found(options={})
      options[:message] ||= "Not Found"
      render_error(status: 404, message: options[:message])
    end

    def render_bad_request(options={})
      options[:message] ||= "Bad Request"
      render_error(status: 400, message: options[:message])
    end

    def render_unauthorized(options={})
      options[:message] ||= "Unauthorized"
      render_error(status: 401, message: options[:message])
    end

    def render_forbidden(options={})
      options[:message] ||= "Forbidden"
      render_error(status: 403, message: options[:message])
    end


    def render_error(options={})
      options[:message] ||= "Error"

      respond_to do |format|
        format.html { render status: options[:status] }

        format.json do
          render :json => {
            :status => options[:status],
            :error  => options[:message]
          }, :status => options[:status]
        end
      end
    end
  end
end
