require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe ApplicationController do
  # before(:all) do
  #   ActiveRecord::Migrator.migrate("#{Rails.root}/db/migrate/core")
  # end
  # 
  # after(:all) do
  #   ActiveRecord::Migrator.rollback("#{Rails.root}/db/migrate/core")
  # end
  
  # ----------------- SESSION TIMEOUT -----------------------
  describe ApplicationController, "with session timeout features" do
    before(:all) do
      plugin_model_configure([:session_timeout])
      plugin_set_controller_config_property(:session_timeout,0.5)
      create_new_user
    end
    
    it "should not reset session before session timeout" do
      login_user
      get :test_should_be_logged_in
      session[:user_id].should_not be_nil
      response.should be_a_success
    end
    
    it "should reset session after session timeout" do
      login_user
      sleep 0.6
      get :test_should_be_logged_in
      session[:user_id].should be_nil
      response.should be_a_redirect
    end
    
    it "with 'session_timeout_from_last_action' should not logout if there was activity" do
      plugin_set_controller_config_property(:session_timeout_from_last_action, true)
      login_user
      sleep 0.3
      get :test_should_be_logged_in
      session[:user_id].should_not be_nil
      sleep 0.3
      get :test_should_be_logged_in
      session[:user_id].should_not be_nil
      response.should be_a_success
    end
    
    it "with 'session_timeout_from_last_action' should logout if there was no activity" do
      plugin_set_controller_config_property(:session_timeout_from_last_action, true)
      login_user
      sleep 0.6
      get :test_should_be_logged_in
      session[:user_id].should be_nil
      response.should be_a_redirect
    end
  end
end