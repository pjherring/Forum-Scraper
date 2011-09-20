class ApplicationController < ActionController::Base
  protect_from_forgery

  USERS = { "camera_linear" => "__fl4sh__" }

  #before_filter :authenticate

  def authenticate
    authenticate_or_request_with_http_digest do |username|
      USERS[username]
    end
  end
  
end
