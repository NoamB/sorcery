require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe ApplicationController do
  
  # ----------------- HTTP BASIC AUTH -----------------------
  describe ApplicationController, "with http basic auth features" do
    before(:all) do
      plugin_model_configure([:http_basic_auth])
      create_new_user
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
  end
end