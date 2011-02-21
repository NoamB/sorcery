require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe ApplicationController do
  
  # ----------------- HTTP BASIC AUTH -----------------------
  describe ApplicationController, "with http basic auth features" do
    before(:all) do
      sorcery_reload!([:http_basic_auth])
      create_new_user
    end
    
    after(:each) do
      logout_user
    end
    
    it "requests basic authentication when before_filter is used" do
      get :test_http_basic_auth
      response.code.should == "401"
    end
    
    it "authenticates from http basic if credentials are sent" do
      @request.env["HTTP_AUTHORIZATION"] = "Basic " + Base64::encode64("#{@user.username}:secret")
      get :test_http_basic_auth, nil, :http_authentication_used => true
      response.should be_a_success
    end
    
    it "fails authentication if credentials are wrong" do
      @request.env["HTTP_AUTHORIZATION"] = "Basic " + Base64::encode64("#{@user.username}:wrong!")
      get :test_http_basic_auth, nil, :http_authentication_used => true
      response.code.should redirect_to root_url
    end
    
    it "should allow configuration option 'controller_to_realm_map'" do
      sorcery_controller_property_set(:controller_to_realm_map, {"1" => "2"})
      Sorcery::Controller::Config.controller_to_realm_map.should == {"1" => "2"}
    end
    
    it "should display the correct realm name configured for the controller" do
      sorcery_controller_property_set(:controller_to_realm_map, {"application" => "Salad"})
      get :test_http_basic_auth
      response.headers["WWW-Authenticate"].should == "Basic realm=\"Salad\""
    end
    
    it "should sign in the user's session on successful login" do
      @request.env["HTTP_AUTHORIZATION"] = "Basic " + Base64::encode64("#{@user.username}:secret")
      get :test_http_basic_auth, nil, :http_authentication_used => true
      session[:user_id].should == User.find_by_username(@user.username).id
    end
  end
end