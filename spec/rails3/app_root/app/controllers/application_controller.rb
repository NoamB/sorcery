class ApplicationController < ActionController::Base
  protect_from_forgery
  
  activate_simple_auth!
end
