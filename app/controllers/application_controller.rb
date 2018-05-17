class ApplicationController < ActionController::Base

  def home
    render html: "", layout: "application"
  end
  
end

