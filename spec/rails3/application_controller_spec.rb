require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "User with no submodules (core)" do
  before(:all) do
    ActiveRecord::Migrator.migrate("#{Rails.root}/db/migrate/core")
  end
  
  after(:all) do
    ActiveRecord::Migrator.rollback("#{Rails.root}/db/migrate/core")
  end
  
  describe ApplicationController, "when app has plugin loaded" do
    it "should respond to the plugin activation class method" do
      ActionController::Base.should respond_to(:activate_simple_auth!)
      ApplicationController.should respond_to(:activate_simple_auth!)
    end
  end
 
  describe ApplicationController, "plugin configuration" do
    after(:each) do
      SimpleAuth::Controller::Config.reset!
    end
  
    it "should enable configuration option 'session_attribute_name'" do    
      plugin_set_controller_config_property(:session_attribute_name, :my_session)
      SimpleAuth::Controller::Config.session_attribute_name.should equal(:my_session)
    end
  
    it "should enable configuration option 'cookies_attribute_name'" do    
      plugin_set_controller_config_property(:cookies_attribute_name, :my_cookies)
      SimpleAuth::Controller::Config.cookies_attribute_name.should equal(:my_cookies)
    end

  end

  describe ApplicationController, "when activated with simple_auth" do
    before(:all) do
      create_new_user
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
      session[:user_id] = 123
      get :test_logout
      session[:user_id].should be_nil
    end
  
    it "logged_in? should return true if logged in" do
      session[:user_id] = 123
      subject.logged_in?.should be_true
    end
  
    it "logged_in? should return false if not logged in" do
      session[:user_id] = nil
      subject.logged_in?.should be_false
    end
  end
end