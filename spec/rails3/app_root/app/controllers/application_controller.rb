class ApplicationController < ActionController::Base
  protect_from_forgery
  
  def test_login
    @user = login(params[:username], params[:password])
    render :text => ""
  end
  
  def test_logout
    logout
    render :text => ""
  end
end
