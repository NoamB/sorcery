require 'spec_helper'

describe SorceryController do
  before(:all) do
    ActiveRecord::Migrator.migrate("#{Rails.root}/db/migrate/brute_force_protection")
    User.reset_column_information
  end

  after(:all) do
    ActiveRecord::Migrator.rollback("#{Rails.root}/db/migrate/brute_force_protection")
  end

  # ----------------- SESSION TIMEOUT -----------------------
  describe SorceryController, "with brute force protection features" do
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
      3.times {get :test_login, :email => 'bla@bla.com', :password => 'blabla'}
      User.find_by_email('bla@bla.com').failed_logins_count.should == 3
    end

    it "should generate unlock token before mail is sent" do
      sorcery_model_property_set(:consecutive_login_retries_amount_limit, 2)
      sorcery_model_property_set(:login_lock_time_period, 0)
      sorcery_model_property_set(:unlock_token_mailer, SorceryMailer)
      3.times {get :test_login, :email => "bla@bla.com", :password => "blabla"}
      ActionMailer::Base.deliveries.last.body.to_s.match(User.find_by_email('bla@bla.com').unlock_token).should_not be_nil
    end

    it "should unlock after entering unlock token" do
      sorcery_model_property_set(:consecutive_login_retries_amount_limit, 2)
      sorcery_model_property_set(:login_lock_time_period, 0)
      sorcery_model_property_set(:unlock_token_mailer, SorceryMailer)
      3.times {get :test_login, :email => "bla@bla.com", :password => "blabla"}
      User.find_by_email('bla@bla.com').unlock_token.should_not be_nil
      token = User.find_by_email('bla@bla.com').unlock_token
      user = User.load_from_unlock_token(token)
      user.should_not be_nil
      user.unlock!
      User.load_from_unlock_token(token).should be_nil
    end

    it "should reset the counter on a good login" do
      # dirty hack for rails 4
      @controller.stub(:register_last_activity_time_to_db)

      sorcery_model_property_set(:consecutive_login_retries_amount_limit, 5)
      3.times {get :test_login, :email => 'bla@bla.com', :password => 'blabla'}
      get :test_login, :email => 'bla@bla.com', :password => 'secret'
      User.find_by_email('bla@bla.com').failed_logins_count.should == 0
    end

    it "should lock user when number of retries reached the limit" do
      User.find_by_email('bla@bla.com').lock_expires_at.should be_nil
      sorcery_model_property_set(:consecutive_login_retries_amount_limit, 1)
      get :test_login, :email => 'bla@bla.com', :password => 'blabla'
      User.find_by_email('bla@bla.com').lock_expires_at.should_not be_nil
    end

    it "should unlock after lock time period passes" do
      sorcery_model_property_set(:consecutive_login_retries_amount_limit, 2)
      sorcery_model_property_set(:login_lock_time_period, 0.2)
      get :test_login, :email => 'bla@bla.com', :password => 'blabla'
      get :test_login, :email => 'bla@bla.com', :password => 'blabla'
      User.find_by_email('bla@bla.com').lock_expires_at.should_not be_nil
      Timecop.travel(Time.now.in_time_zone + 0.3)
      get :test_login, :email => 'bla@bla.com', :password => 'blabla'
      User.find_by_email('bla@bla.com').lock_expires_at.should be_nil
    end

    it "should not unlock if time period is 0 (permanent lock)" do
      sorcery_model_property_set(:consecutive_login_retries_amount_limit, 2)
      sorcery_model_property_set(:login_lock_time_period, 0)
      get :test_login, :email => 'bla@bla.com', :password => 'blabla'
      get :test_login, :email => 'bla@bla.com', :password => 'blabla'
      unlock_date = User.find_by_email('bla@bla.com').lock_expires_at
      Timecop.travel(Time.now.in_time_zone + 1)
      get :test_login, :email => 'bla@bla.com', :password => 'blabla'
      User.find_by_email('bla@bla.com').lock_expires_at.to_s.should == unlock_date.to_s
    end

    context "unlock_token_mailer_disabled is true" do

      before(:each) do
        sorcery_model_property_set(:unlock_token_mailer_disabled, true)
        sorcery_model_property_set(:consecutive_login_retries_amount_limit, 2)
        sorcery_model_property_set(:login_lock_time_period, 0)
        sorcery_model_property_set(:unlock_token_mailer, SorceryMailer)
      end

      it "should generate unlock token after user locked" do
        3.times {get :test_login, :email => "bla@bla.com", :password => "blabla"}
        User.find_by_email('bla@bla.com').unlock_token.should_not be_nil
      end

      it "should *not* automatically send unlock mail" do
        old_size = ActionMailer::Base.deliveries.size
        3.times {get :test_login, :email => "bla@bla.com", :password => "blabla"}
        ActionMailer::Base.deliveries.size.should == old_size
      end

    end

    context "unlock_token_mailer_disabled is false" do

      before(:each) do
        sorcery_model_property_set(:unlock_token_mailer_disabled, false)
        sorcery_model_property_set(:consecutive_login_retries_amount_limit, 2)
        sorcery_model_property_set(:login_lock_time_period, 0)
        sorcery_model_property_set(:unlock_token_mailer, SorceryMailer)
      end

      it "should set the unlock token after user locked" do
        3.times {get :test_login, :email => "bla@bla.com", :password => "blabla"}
        User.find_by_email('bla@bla.com').unlock_token.should_not be_nil
      end

      it "should automatically send unlock mail" do
        old_size = ActionMailer::Base.deliveries.size
        3.times {get :test_login, :email => "bla@bla.com", :password => "blabla"}
        ActionMailer::Base.deliveries.size.should == old_size + 1
      end

    end

  end
end
