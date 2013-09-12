module AssetHostCore
  class ApplicationController < ::ApplicationController


    private

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
