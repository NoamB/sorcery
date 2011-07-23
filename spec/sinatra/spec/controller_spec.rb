require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Sinatra::Application do
 
  # ----------------- PLUGIN CONFIGURATION -----------------------
  describe "plugin configuration" do
    before(:all) do
      sorcery_reload!
    end
    
    after(:each) do
      Sorcery::Controller::Config.reset!
      sorcery_reload!
    end
    
    it "should enable configuration option 'user_class'" do
      sorcery_controller_property_set(:user_class, "TestUser")
      Sorcery::Controller::Config.user_class.should == "TestUser"
    end
    
    it "should enable configuration option 'not_authenticated_action'" do
      sorcery_controller_property_set(:not_authenticated_action, :my_action)
      Sorcery::Controller::Config.not_authenticated_action.should equal(:my_action)
    end
    
  end

  # ----------------- PLUGIN ACTIVATED -----------------------
  describe Sinatra::Application, "when activated with sorcery" do
    
    before(:all) do
      User.delete_all
      create_new_user
    end
  
    after(:each) do
      Sorcery::Controller::Config.reset!
      sorcery_controller_property_set(:user_class, User)
    end
    
    it "should respond to the instance method login" do
      get_sinatra_app(subject).should respond_to(:login)
    end
      
    it "should respond to the instance method logout" do
      get_sinatra_app(subject).should respond_to(:logout)
    end
      
    it "should respond to the instance method logged_in?" do
      get_sinatra_app(subject).should respond_to(:logged_in?)
    end
    
    it "should respond to the instance method current_user" do
      get_sinatra_app(subject).should respond_to(:current_user)
    end
  
    it "login(username,password) should return the user when success and set the session with user.id" do
      get "/test_login", :username => 'gizmo', :password => 'secret'
      assigns[:user].should == @user
      session[:user_id].should == @user.id
    end
  
    it "login(username,password) should return nil and not set the session when failure" do
      get "/test_login", :username => 'gizmo', :password => 'opensesame!'
      assigns[:user].should be_nil
      session[:user_id].should be_nil
    end
  
    it "logout should clear the session" do
      get "/test_logout"
      session[:user_id].should be_nil
    end
  
    it "logged_in? should return true if logged in" do
      get "/test_login", :username => 'gizmo', :password => 'secret'
      assigns[:logged_in].should be_true
    end
  
    it "logged_in? should return false if not logged in" do
      get "/test_login", :username => 'gizmo', :password => 'opensesame!'
      assigns[:logged_in].should be_false
    end
    
    it "current_user should return the user instance if logged in" do
      create_new_user
      get "/test_current_user", :id => @user.id
      assigns[:current_user].should == @user
    end
    
    it "current_user should return false if not logged in" do
      get "/test_logout"
      assigns[:current_user].should == false
    end
    
    it "should respond to 'require_login'" do
      get_sinatra_app(subject).should respond_to(:require_login)
    end
    
    it "should call the configured 'not_authenticated_action' when authenticate before_filter fails" do
      sorcery_controller_property_set(:not_authenticated_action, :test_not_authenticated_action)
      get "/test_logout"
      last_response.body.should == "test_not_authenticated_action"
    end
    
    it "require_login before_filter should save the url that the user originally wanted" do
      sorcery_controller_property_set(:not_authenticated_action, :not_authenticated2)
      get "/some_action"
      assigns[:session][:return_to_url].should == "http://example.org/some_action"
      last_response.status.should == 302
      last_response.should redirect_to("http://example.org/")
    end
    
    it "on successful login the user should be redirected to the url he originally wanted" do
      post "/test_return_to", :username => 'gizmo', :password => 'secret', :return_to_url => "http://example.org/blabla"
      last_response.should redirect_to("http://example.org/blabla")
    end
    
  end
  
end