class ApplicationController < ActionController::Base
  protect_from_forgery
  
  before_filter :authenticate, :only => [:test_logout]
  
  def index
    render :text => ""
  end
  
  def test_login
    @user = login(params[:username], params[:password])
    render :text => ""
  end
  
  def test_logout
    logout
    render :text => ""
  end
  
  def test_login_with_remember
    @user = login(params[:username], params[:password])
    remember_me!
    
    render :text => ""
  end
  
  def test_not_authenticated_action
    render :text => "test_not_authenticated_action"
  end
  
  protected
  
  def not_authenticated
    redirect_to root_path
  end
end
