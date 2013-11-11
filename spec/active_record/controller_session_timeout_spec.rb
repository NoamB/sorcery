require 'spec_helper'

describe SorceryController do

  # ----------------- SESSION TIMEOUT -----------------------
  describe SorceryController, "with session timeout features" do
    before(:all) do
      sorcery_reload!([:session_timeout])
      sorcery_controller_property_set(:session_timeout,0.5)
      create_new_user
    end

    after(:each) do
      Timecop.return
    end

    it "should not reset session before session timeout" do
      login_user
      get :test_should_be_logged_in
      session[:user_id].should_not be_nil
      response.should be_a_success
    end

    it "should reset session after session timeout" do
      login_user
      Timecop.travel(Time.now.in_time_zone+0.6)
      get :test_should_be_logged_in
      session[:user_id].should be_nil
      response.should be_a_redirect
    end

    context "with 'session_timeout_from_last_action'" do
      it "should not logout if there was activity" do
        sorcery_controller_property_set(:session_timeout_from_last_action, true)
        get :test_login, :email => 'bla@bla.com', :password => 'secret'
        Timecop.travel(Time.now.in_time_zone+0.3)
        get :test_should_be_logged_in
        session[:user_id].should_not be_nil
        Timecop.travel(Time.now.in_time_zone+0.3)
        get :test_should_be_logged_in
        session[:user_id].should_not be_nil
        response.should be_a_success
      end

      it "with 'session_timeout_from_last_action' should logout if there was no activity" do
        sorcery_controller_property_set(:session_timeout_from_last_action, true)
        get :test_login, :email => 'bla@bla.com', :password => 'secret'
        Timecop.travel(Time.now.in_time_zone+0.6)
        get :test_should_be_logged_in
        session[:user_id].should be_nil
        response.should be_a_redirect
      end
    end
  end
end