require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe ApplicationController do
  before(:all) do
    ActiveRecord::Migrator.migrate("#{Rails.root}/db/migrate/core")
  end
  
  after(:all) do
    ActiveRecord::Migrator.rollback("#{Rails.root}/db/migrate/core")
  end
 
  # ----------------- PLUGIN CONFIGURATION -----------------------
  describe ApplicationController, "plugin configuration" do
    before(:all) do
      plugin_model_configure
    end
    
    after(:each) do
      Sorcery::Controller::Config.reset!
      plugin_model_configure
    end
    
    it "should enable configuration option 'user_class'" do
      plugin_set_controller_config_property(:user_class, TestUser)
      Sorcery::Controller::Config.user_class.should equal(TestUser)
    end
    
    it "should enable configuration option 'session_attribute_name'" do
      plugin_set_controller_config_property(:session_attribute_name, :my_session)
      Sorcery::Controller::Config.session_attribute_name.should equal(:my_session)
    end
    
    it "should enable configuration option 'cookies_attribute_name'" do
      plugin_set_controller_config_property(:cookies_attribute_name, :my_cookies)
      Sorcery::Controller::Config.cookies_attribute_name.should equal(:my_cookies)
    end
    
    it "should enable configuration option 'not_authenticated_action'" do
      plugin_set_controller_config_property(:not_authenticated_action, :my_action)
      Sorcery::Controller::Config.not_authenticated_action.should equal(:my_action)
    end
    
  end

  # ----------------- PLUGIN ACTIVATED -----------------------
  describe ApplicationController, "when activated with sorcery" do
    before(:all) do
      create_new_user
    end
  
    after(:each) do
      Sorcery::Controller::Config.reset!
      plugin_set_controller_config_property(:user_class, User)
    end
    
    it "should respond to the instance method login" do
      should respond_to(:login)
    end
  
    it "should respond to the instance method logout" do
      should respond_to(:logout)
    end
  
    it "should respond to the instance method logged_in?" do
      should respond_to(:logged_in?)
    end
    
    it "should respond to the instance method logged_in_user" do
      should respond_to(:logged_in_user)
    end
  
    it "login(username,password) should return the user when success and set the session with user.id" do
      get :test_login, :username => 'gizmo', :password => 'secret'
      assigns[:user].should == @user
      session[:user_id].should == @user.id
    end
  
    it "login(username,password) should return nil and not set the session when failure" do
      get :test_login, :username => 'gizmo', :password => 'opensesame!'
      assigns[:user].should be_nil
      session[:user_id].should be_nil
    end
  
    it "logout should clear the session" do
      cookies[:remember_me_token] = nil
      session[:user_id] = @user.id
      get :test_logout
      session[:user_id].should be_nil
    end
  
    it "logged_in? should return true if logged in" do
      session[:user_id] = @user.id
      subject.logged_in?.should be_true
    end
  
    it "logged_in? should return false if not logged in" do
      session[:user_id] = nil
      subject.logged_in?.should be_false
    end
    
    it "logged_in_user should return the user instance if logged in" do
      create_new_user
      session[:user_id] = @user.id
      subject.logged_in_user.should == @user
    end
    
    it "logged_in_user should return false if not logged in" do
      session[:user_id] = nil
      subject.logged_in_user.should == false
    end
    
    it "should respond to 'authenticate'" do
      should respond_to(:authenticate)
    end
    
    it "should call the configured 'not_authenticated_action' when authenticate before_filter fails" do
      session[:user_id] = nil
      plugin_set_controller_config_property(:not_authenticated_action, :test_not_authenticated_action)
      get :test_logout
      response.body.should == "test_not_authenticated_action"
    end
    
  end
  
  # ----------------- REMEMBER ME -----------------------
  describe ApplicationController, "with remember me features" do
    before(:all) do
      ActiveRecord::Migrator.migrate("#{Rails.root}/db/migrate/remember_me")
      plugin_model_configure([:remember_me])
      create_new_user
    end
    
    after(:all) do
      ActiveRecord::Migrator.rollback("#{Rails.root}/db/migrate/remember_me")
    end
    
    it "should set cookie on remember_me!" do
      post :test_login_with_remember, :username => 'gizmo', :password => 'secret'
      cookies["remember_me_token"].should == assigns[:logged_in_user].remember_me_token
    end
    
    it "should clear cookie on forget_me!" do
      cookies["remember_me_token"] == {:value => 'asd54234dsfsd43534', :expires => 3600}
      get :test_logout
      cookies["remember_me_token"].should == nil
    end
    
    it "login(username,password,remember_me) should login and remember" do
      post :test_login_with_remember_in_login, :username => 'gizmo', :password => 'secret', :remember => "1"
      cookies["remember_me_token"].should_not be_nil
      cookies["remember_me_token"].should == assigns[:user].remember_me_token
    end
    
    it "logout should also forget_me!" do
      session[:user_id] = @user.id
      get :test_logout_with_remember
      cookies["remember_me_token"].should == nil
    end
    
    it "should login_from_cookie" do
      session[:user_id] = @user.id
      subject.remember_me!
      subject.instance_eval do
        @logged_in_user = nil
      end
      session[:user_id] = nil
      get :test_login_from_cookie
      assigns[:logged_in_user].should == @user
    end
  end
  
  # ----------------- SESSION TIMEOUT -----------------------
  describe ApplicationController, "with session timeout features" do
    before(:all) do
      plugin_model_configure([:session_timeout])
      plugin_set_controller_config_property(:session_timeout,0.5)
      create_new_user
    end
    
    it "should not reset session before session timeout" do
      subject.send(:login_user,@user)
      get :test_should_be_logged_in
      session[:user_id].should_not be_nil
      response.should be_a_success
    end
    
    it "should reset session after session timeout" do
      subject.send(:login_user,@user)
      sleep 0.6
      get :test_should_be_logged_in
      session[:user_id].should be_nil
      response.should be_a_redirect
    end
    
    it "with 'session_timeout_from_last_action' should not logout if there was activity" do
      plugin_set_controller_config_property(:session_timeout_from_last_action, true)
      subject.send(:login_user,@user)
      sleep 0.3
      get :test_should_be_logged_in
      session[:user_id].should_not be_nil
      sleep 0.3
      get :test_should_be_logged_in
      session[:user_id].should_not be_nil
      response.should be_a_success
    end
    
    it "with 'session_timeout_from_last_action' should logout if there was no activity" do
      plugin_set_controller_config_property(:session_timeout_from_last_action, true)
      subject.send(:login_user,@user)
      sleep 0.6
      get :test_should_be_logged_in
      session[:user_id].should be_nil
      response.should be_a_redirect
    end
  end
end