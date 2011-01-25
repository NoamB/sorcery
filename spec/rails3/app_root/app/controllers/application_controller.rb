class ApplicationController < ActionController::Base
  protect_from_forgery
  
  before_filter :authenticate, :only => [:test_logout]
  
  def index
    render :text => ""
  end
  
  def test_login
    @user = User.new(params[:user])
    @user = login(@user)
    render :text => ""
  end
  
  def test_logout
    logout
    render :text => ""
  end
  
  def test_login_with_remember
    @user = User.new(params[:user])
    @user = login(@user)
    remember_me!
    
    render :text => ""
  end
  
  def test_not_logged_in_action
    render :text => "test_not_logged_in_action"
  end
  
  protected
  
  def access_denied
    redirect_to root_path
  end
end
