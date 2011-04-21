require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe ApplicationController do
 
  # ----------------- PLUGIN CONFIGURATION -----------------------
  describe ApplicationController, "plugin configuration" do
    before(:all) do
      sorcery_reload!
    end
    
    after(:each) do
      Sorcery::Controller::Config.reset!
      sorcery_reload!
    end
    
    it "should enable configuration option 'user_class'" do
      sorcery_controller_property_set(:user_class, TestUser)
      Sorcery::Controller::Config.user_class.should equal(TestUser)
    end
    
    it "should enable configuration option 'not_authenticated_action'" do
      sorcery_controller_property_set(:not_authenticated_action, :my_action)
      Sorcery::Controller::Config.not_authenticated_action.should equal(:my_action)
    end
    
  end

  # ----------------- PLUGIN ACTIVATED -----------------------
  describe ApplicationController, "when activated with sorcery" do
    before(:all) do
      User.delete_all
      create_new_user
    end
  
    after(:each) do
      Sorcery::Controller::Config.reset!
      sorcery_controller_property_set(:user_class, User)
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
    
    it "should respond to the instance method current_user" do
      should respond_to(:current_user)
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
    
    it "current_user should return the user instance if logged in" do
      create_new_user
      session[:user_id] = @user.id
      subject.current_user.should == @user
    end
    
    it "current_user should return false if not logged in" do
      session[:user_id] = nil
      subject.current_user.should == false
    end
    
    it "should respond to 'require_login'" do
      should respond_to(:require_login)
    end
    
    it "should call the configured 'not_authenticated_action' when authenticate before_filter fails" do
      session[:user_id] = nil
      sorcery_controller_property_set(:not_authenticated_action, :test_not_authenticated_action)
      get :test_logout
      response.body.should == "test_not_authenticated_action"
    end
    
    it "require_login before_filter should save the url that the user originally wanted" do
      get :some_action
      session[:return_to_url].should == "http://test.host/application/some_action"
      response.should redirect_to("http://test.host/")
    end
    
    it "on successful login the user should be redirected to the url he originally wanted" do
      session[:return_to_url] = "http://test.host/some_action"
      post :test_return_to, :username => 'gizmo', :password => 'secret'
      response.should redirect_to("http://test.host/some_action")
      flash[:notice].should == "haha!"
    end
    
  end
  
end