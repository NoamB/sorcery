require 'oauth'

class ApplicationController < ActionController::Base
  protect_from_forgery
  
  #before_filter :validate_session, :only => [:test_should_be_logged_in] if defined?(:validate_session)
  before_filter :require_login_from_http_basic, :only => [:test_http_basic_auth]
  before_filter :require_login, :only => [:test_logout, :test_should_be_logged_in, :some_action]
  
  def index
    render :text => ""
  end
  
  def some_action
    render :nothing => true
  end
  
  def test_login
    @user = login(params[:username], params[:password])
    render :text => ""
  end
  
  def test_return_to
    @user = login(params[:username], params[:password])
    return_or_redirect_to(:index, :notice => 'haha!')
  end
  
  def test_logout
    logout
    render :text => ""
  end
  
  def test_logout_with_remember
    remember_me!
    logout
    render :text => ""
  end
  
  def test_login_with_remember
    @user = login(params[:username], params[:password])
    remember_me!
    
    render :text => ""
  end
  
  def test_login_with_remember_in_login
    @user = login(params[:username], params[:password], params[:remember])
    
    render :text => ""
  end
  
  def test_login_from_cookie
    @user = current_user
    render :text => ""
  end
  
  def test_not_authenticated_action
    render :text => "test_not_authenticated_action"
  end
  
  def test_should_be_logged_in
    render :text => ""
  end
  
  def test_http_basic_auth
    render :text => "HTTP Basic Auth"
  end
  
  def auth_at_provider_test
    auth_at_provider(:twitter)
  end
  
  protected
  
  

end
