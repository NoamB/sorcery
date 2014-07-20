require 'spec_helper'

describe SorceryController do

  let!(:user) { create_new_user }

  # ----------------- SESSION TIMEOUT -----------------------
  context "with session timeout features" do
    before(:all) do
      sorcery_reload!([:session_timeout])
      sorcery_controller_property_set(:session_timeout,0.5)
    end

    after(:each) do
      Timecop.return
    end

    it "does not reset session before session timeout" do
      login_user
      get :test_should_be_logged_in

      expect(session[:user_id]).not_to be_nil
      expect(response).to be_a_success
    end

    it "resets session after session timeout" do
      login_user
      Timecop.travel(Time.now.in_time_zone+0.6)
      get :test_should_be_logged_in

      expect(session[:user_id]).to be_nil
      expect(response).to be_a_redirect
    end

    it "works if the session is stored as a string or a Time" do
      session[:login_time] = Time.now.to_s
      get :test_login, :email => 'bla@bla.com', :password => 'secret'

      expect(session[:user_id]).not_to be_nil
      expect(response).to be_a_success
    end

    context "with 'session_timeout_from_last_action'" do
      it "does not logout if there was activity" do
        sorcery_controller_property_set(:session_timeout_from_last_action, true)
        get :test_login, :email => 'bla@bla.com', :password => 'secret'
        Timecop.travel(Time.now.in_time_zone+0.3)
        get :test_should_be_logged_in

        expect(session[:user_id]).not_to be_nil

        Timecop.travel(Time.now.in_time_zone+0.3)
        get :test_should_be_logged_in

        expect(session[:user_id]).not_to be_nil
        expect(response).to be_a_success
      end

      it "with 'session_timeout_from_last_action' logs out if there was no activity" do
        sorcery_controller_property_set(:session_timeout_from_last_action, true)
        get :test_login, :email => 'bla@bla.com', :password => 'secret'
        Timecop.travel(Time.now.in_time_zone+0.6)
        get :test_should_be_logged_in

        expect(session[:user_id]).to be_nil
        expect(response).to be_a_redirect
      end
    end
  end
end
