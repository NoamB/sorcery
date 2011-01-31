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
  describe ApplicationController, "with brute force protection features" do
    before(:all) do
      plugin_model_configure([:brute_force_protection])
      create_new_user
    end
    
    after(:each) do
      Sorcery::Controller::Config.reset!
      plugin_set_controller_config_property(:user_class, User)
    end
    
    it "should have configuration for 'login_retries_amount_allowed' per session" do
      plugin_set_controller_config_property(:login_retries_amount_allowed, 32)
      Sorcery::Controller::Config.login_retries_amount_allowed.should equal(32)
    end
    
    it "should have configuration for 'login_retries_counter_reset_time'" do
      plugin_set_controller_config_property(:login_retries_time_period, 32)
      Sorcery::Controller::Config.login_retries_time_period.should equal(32)
    end
    
    it "should count login retries per session" do
      3.times {get :test_login, :username => 'gizmo', :password => 'blabla'}
      session[:failed_logins].should == 3
    end
    
    it "should reset the counter if enough time has passed" do
      plugin_set_controller_config_property(:login_retries_amount_allowed, 5)
      plugin_set_controller_config_property(:login_retries_time_period, 0.5)
      get :test_login, :username => 'gizmo', :password => 'blabla'
      sleep 1
      get :test_login, :username => 'gizmo', :password => 'blabla'
      session[:failed_logins].should == 1
    end
    
    it "should ban session when number of retries reached within an amount of time" do
      plugin_set_controller_config_property(:login_retries_amount_allowed, 1)
      plugin_set_controller_config_property(:login_retries_time_period, 50)
      get :test_login, :username => 'gizmo', :password => 'blabla'
      get :test_login, :username => 'gizmo', :password => 'blabla'
      session[:banned].should == true
    end

    it "should clear ban after ban time limit passes" do
      plugin_set_controller_config_property(:login_retries_amount_allowed, 1)
      plugin_set_controller_config_property(:login_retries_time_period, 50)
      plugin_set_controller_config_property(:login_ban_time_period, 0.5)
      get :test_login, :username => 'gizmo', :password => 'blabla'
      get :test_login, :username => 'gizmo', :password => 'blabla'
      session[:banned].should == true
      sleep 0.6
      get :test_login, :username => 'gizmo', :password => 'blabla'
      session[:banned].should == nil
    end
    
    it "banned session calls the configured banned action" do
      plugin_set_controller_config_property(:login_retries_amount_allowed, 1)
      plugin_set_controller_config_property(:login_retries_time_period, 50)
      plugin_set_controller_config_property(:login_ban_time_period, 50)
      get :test_login, :username => 'gizmo', :password => 'blabla'
      get :test_login, :username => 'gizmo', :password => 'blabla'
      get :test_login, :username => 'gizmo', :password => 'blabla'
      session[:banned].should == true
      response.body.should == " "
    end
  end
end