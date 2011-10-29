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
      sorcery_reload!([:brute_force_protection])
      create_new_user
    end
    
    after(:each) do
      Sorcery::Controller::Config.reset!
      sorcery_controller_property_set(:user_class, User)
      Timecop.return
    end
    
    it "should count login retries" do
      3.times {get :test_login, :username => 'gizmo', :password => 'blabla'}
      User.find_by_username('gizmo').failed_logins_count.should == 3
    end
    
    it "should reset the counter on a good login" do
      sorcery_model_property_set(:consecutive_login_retries_amount_limit, 5)
      3.times {get :test_login, :username => 'gizmo', :password => 'blabla'}
      get :test_login, :username => 'gizmo', :password => 'secret'
      User.find_by_username('gizmo').failed_logins_count.should == 0
    end
    
    it "should lock user when number of retries reached the limit" do
      User.find_by_username('gizmo').lock_expires_at.should be_nil
      sorcery_model_property_set(:consecutive_login_retries_amount_limit, 1)
      get :test_login, :username => 'gizmo', :password => 'blabla'
      User.find_by_username('gizmo').lock_expires_at.should_not be_nil
    end

    it "should unlock after lock time period passes" do
      sorcery_model_property_set(:consecutive_login_retries_amount_limit, 2)
      sorcery_model_property_set(:login_lock_time_period, 0.2)
      get :test_login, :username => 'gizmo', :password => 'blabla'
      get :test_login, :username => 'gizmo', :password => 'blabla'
      User.find_by_username('gizmo').lock_expires_at.should_not be_nil
      Timecop.travel(Time.now.in_time_zone + 0.3)
      get :test_login, :username => 'gizmo', :password => 'blabla'
      User.find_by_username('gizmo').lock_expires_at.should be_nil
    end

    it "should not unlock if time period is 0 (permanent lock)" do
      sorcery_model_property_set(:consecutive_login_retries_amount_limit, 2)
      sorcery_model_property_set(:login_lock_time_period, 0)
      get :test_login, :username => 'gizmo', :password => 'blabla'
      get :test_login, :username => 'gizmo', :password => 'blabla'
      unlock_date = User.find_by_username('gizmo').lock_expires_at
      Timecop.travel(Time.now.in_time_zone + 1)
      get :test_login, :username => 'gizmo', :password => 'blabla'
      User.find_by_username('gizmo').lock_expires_at.to_s.should == unlock_date.to_s
    end
  end
end