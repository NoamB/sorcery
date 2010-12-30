require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe ApplicationController, "when app has plugin loaded" do
  it "should respond to the plugin activation class method" do
    ActionController::Base.should respond_to(:activate_simple_auth!)
    ApplicationController.should respond_to(:activate_simple_auth!)
  end
end

def plugin_set_controller_config_property(property, value)
  ApplicationController.class_eval do
    activate_simple_auth! do |config|
      config.send("#{property}=".to_sym, value)
    end
  end
end
 
describe ApplicationController, "plugin configuration" do
  after(:each) do
    SimpleAuth::Controller::Config.reset_to_defaults!
  end
  
  it "should enable configuration option 'session_attribute_name'" do    
    plugin_set_controller_config_property(:session_attribute_name, :my_session)
    SimpleAuth::Controller::Config.session_attribute_name.should equal(:my_session)
  end

end

describe ApplicationController, "when activated with simple_auth" do
  before(:all) do
    ApplicationController.class_eval do
      def test_login
        @user = login(params[:username], params[:password])
        render :text => ""
      end
      
      def test_logout
        logout
        render :text => ""
      end
    end
    
    AppRoot::Application.routes.draw do
      match '/test_login', :to => "application#test_login"
      match '/test_logout', :to => "application#test_logout"
    end
    
    @user = User.new(:username => 'gizmo', :email => "bla@bla.com", :crypted_password => User.encrypt('secret'))
    @user.save!
  end
  
  it "should respond to the class method login" do
    should respond_to(:login)
  end
  
  it "should respond to the class method logout" do
    should respond_to(:logout)
  end
  
  it "should respond to the class method logged_in?" do
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