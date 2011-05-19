require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'base64'

describe Modular do
  
  # ----------------- HTTP BASIC AUTH -----------------------
  describe Modular, "with http basic auth features" do
    before(:all) do
      sorcery_reload!([:http_basic_auth])
      create_new_user
    end
    
    after(:each) do
      get "/test_logout"
    end
    
    it "requests basic authentication when before_filter is used" do
      session[:http_authentication_used] = nil
      get "/test_http_basic_auth"
      last_response.status.should == 401
      session[:http_authentication_used].should == true
    end
    
    it "authenticates from http basic if credentials are sent" do
      session[:http_authentication_used] = true
      get "/test_http_basic_auth", {}, {"HTTP_AUTHORIZATION" => "Basic " + Base64::encode64("#{@user.username}:secret")}
      last_response.should be_ok
    end
    
    it "fails authentication if credentials are wrong" do
      session[:http_authentication_used] = true
      get "/test_http_basic_auth", {}, {"HTTP_AUTHORIZATION" => "Basic " + Base64::encode64("#{@user.username}:wrong!")}
      last_response.should redirect_to 'http://example.org/'
    end
    
    it "should allow configuration option 'controller_to_realm_map'" do
      sorcery_controller_property_set(:controller_to_realm_map, {"1" => "2"})
      Sorcery::Controller::Config.controller_to_realm_map.should == {"1" => "2"}
    end
    
    it "should display the correct realm name configured for the controller" do
      sorcery_controller_property_set(:controller_to_realm_map, {"application" => "Salad"})
      get "/test_http_basic_auth"
      last_response.headers["WWW-Authenticate"].should == "Basic realm=\"Salad\""
    end
    
    it "should sign in the user's session on successful login" do
      session[:http_authentication_used] = true
      get "/test_http_basic_auth", {}, {"HTTP_AUTHORIZATION" => "Basic " + Base64::encode64("#{@user.username}:secret")}
      session[:user_id].should == User.find_by_username(@user.username).id
    end
  end
end