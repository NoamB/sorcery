require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe ApplicationController do
  before(:all) do
    ActiveRecord::Migrator.migrate("#{Rails.root}/db/migrate/brute_force_protection")
  end
  
  after(:all) do
    ActiveRecord::Migrator.rollback("#{Rails.root}/db/migrate/brute_force_protection")
  end
  
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
    
    it "should count login retries" do
      3.times {get :test_login, :username => 'gizmo', :password => 'blabla'}
      User.find_by_username('gizmo').failed_logins_count.should == 3
    end
    
    it "should reset the counter on a good login" do
      plugin_set_model_config_property(:consecutive_login_retries_amount_allowed, 5)
      3.times {get :test_login, :username => 'gizmo', :password => 'blabla'}
      get :test_login, :username => 'gizmo', :password => 'secret'
      User.find_by_username('gizmo').failed_logins_count.should == 0
    end
    
    it "should lock user when number of retries reached the limit" do
      User.find_by_username('gizmo').lock_expires_at.should be_nil
      plugin_set_model_config_property(:consecutive_login_retries_amount_allowed, 1)
      get :test_login, :username => 'gizmo', :password => 'blabla'
      User.find_by_username('gizmo').lock_expires_at.should_not be_nil
    end

    it "should unlock after lock time period passes" do
      plugin_set_model_config_property(:consecutive_login_retries_amount_allowed, 2)
      plugin_set_model_config_property(:login_lock_time_period, 0.2)
      get :test_login, :username => 'gizmo', :password => 'blabla'
      get :test_login, :username => 'gizmo', :password => 'blabla'
      User.find_by_username('gizmo').lock_expires_at.should_not be_nil
      sleep 0.3
      get :test_login, :username => 'gizmo', :password => 'blabla'
      User.find_by_username('gizmo').lock_expires_at.should be_nil
    end

  end
end