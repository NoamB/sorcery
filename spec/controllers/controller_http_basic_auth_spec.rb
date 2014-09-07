require 'spec_helper'

describe SorceryController do

  let(:user) { double("user", id: 42, email: 'bla@bla.com') }

  describe  "with http basic auth features" do
    before(:all) do
      sorcery_reload!([:http_basic_auth])

      sorcery_controller_property_set(:controller_to_realm_map, {"sorcery" => "sorcery"})
    end

    after(:each) do
      logout_user
    end

    it "requests basic authentication when before_filter is used" do
      get :test_http_basic_auth

      expect(response.status).to eq 401
    end

    it "authenticates from http basic if credentials are sent" do
      # dirty hack for rails 4
      allow(subject).to receive(:register_last_activity_time_to_db)

      @request.env["HTTP_AUTHORIZATION"] = "Basic #{Base64::encode64("#{user.email}:secret")}"
      expect(User).to receive('authenticate').with('bla@bla.com', 'secret').and_return(user)
      get :test_http_basic_auth, nil, http_authentication_used: true

      expect(response).to be_a_success
    end

    it "fails authentication if credentials are wrong" do
      @request.env["HTTP_AUTHORIZATION"] = "Basic #{Base64::encode64("#{user.email}:wrong!")}"
      expect(User).to receive('authenticate').with('bla@bla.com', 'wrong!').and_return(nil)
      get :test_http_basic_auth, nil, http_authentication_used: true

      expect(response).to redirect_to root_url
    end

    it "allows configuration option 'controller_to_realm_map'" do
      sorcery_controller_property_set(:controller_to_realm_map, {"1" => "2"})

      expect(Sorcery::Controller::Config.controller_to_realm_map).to eq({"1" => "2"})
    end

    it "displays the correct realm name configured for the controller" do
      sorcery_controller_property_set(:controller_to_realm_map, {"sorcery" => "Salad"})
      get :test_http_basic_auth

      expect(response.headers["WWW-Authenticate"]).to eq "Basic realm=\"Salad\""
    end

    it "signs in the user's session on successful login" do
      # dirty hack for rails 4
      allow(controller).to receive(:register_last_activity_time_to_db)

      @request.env["HTTP_AUTHORIZATION"] = "Basic #{Base64::encode64("#{user.email}:secret")}"
      expect(User).to receive('authenticate').with('bla@bla.com', 'secret').and_return(user)

      get :test_http_basic_auth, nil, http_authentication_used: true

      expect(session[:user_id]).to eq "42"
    end
  end
end
