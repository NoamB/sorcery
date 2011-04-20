require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Sinatra::Application do
  
  # ----------------- SESSION TIMEOUT -----------------------
  describe Sinatra::Application, "with session timeout features" do
    before(:all) do
      sorcery_reload!([:session_timeout])
      sorcery_controller_property_set(:session_timeout,0.5)
      create_new_user
    end
    
    after(:each) do
      Timecop.return
    end
    
    it "should not reset session before session timeout" do
      session[:user_id] = User.first.id
      get "/test_should_be_logged_in"
      last_response.should be_ok
    end
    
    it "should reset session after session timeout" do
      get "/test_login", :username => 'gizmo', :password => 'secret'
      session[:user_id].should_not be_nil
      Timecop.travel(Time.now+0.6)
      get "/test_should_be_logged_in"
      last_response.should be_a_redirect
    end
    
    it "with 'session_timeout_from_last_action' should not logout if there was activity" do
      session[:user_id] = nil
      sorcery_controller_property_set(:session_timeout,2)
      sorcery_controller_property_set(:session_timeout_from_last_action, true)
      get "/test_login", :username => 'gizmo', :password => 'secret'
      Timecop.travel(Time.now+1)
      get "/test_should_be_logged_in"
      session[:user_id].should_not be_nil
      Timecop.travel(Time.now+1)
      get "/test_should_be_logged_in"
      session[:user_id].should_not be_nil
      last_response.should be_ok
    end
    
    it "with 'session_timeout_from_last_action' should logout if there was no activity" do
      sorcery_controller_property_set(:session_timeout,0.5)
      sorcery_controller_property_set(:session_timeout_from_last_action, true)
      get "/test_login", :username => 'gizmo', :password => 'secret'
      Timecop.travel(Time.now+0.6)
      get "/test_should_be_logged_in"
      session[:user_id].should be_nil
      last_response.should be_a_redirect
    end
    
  end
end