require 'spec_helper'

describe SorceryController do
  before(:all) do
    ActiveRecord::Migrator.migrate("#{Rails.root}/db/migrate/activity_logging")
    User.reset_column_information
  end

  after(:all) do
    ActiveRecord::Migrator.rollback("#{Rails.root}/db/migrate/activity_logging")

    sorcery_controller_property_set(:register_login_time, true)
    sorcery_controller_property_set(:register_logout_time, true)
    sorcery_controller_property_set(:register_last_activity_time, true)
    # sorcery_controller_property_set(:last_login_from_ip_address_name, true)
  end

  # ----------------- ACTIVITY LOGGING -----------------------
  describe SorceryController, "with activity logging features" do
    before(:all) do
      sorcery_reload!([:activity_logging])
    end

    before(:each) do
      create_new_user
    end

    after(:each) do
      User.delete_all
    end

    specify { subject.should respond_to(:current_users) }

    it "'current_users' should be empty when no users are logged in" do
      subject.current_users.size.should == 0
    end

    it "should log login time on login" do
      now = Time.now.in_time_zone
      login_user
      @user.last_login_at.should_not be_nil
      @user.last_login_at.to_s(:db).should >= now.to_s(:db)
      @user.last_login_at.to_s(:db).should <= (now+2).to_s(:db)
    end

    it "should log logout time on logout" do
      login_user
      now = Time.now.in_time_zone
      logout_user

      User.last.last_logout_at.should_not be_nil

      User.last.last_logout_at.to_s(:db).should >= now.to_s(:db)
      User.last.last_logout_at.to_s(:db).should <= (now+2).to_s(:db)
    end

    it "should log last activity time when logged in" do
      sorcery_controller_property_set(:register_last_activity_time, true)

      login_user
      now = Time.now.in_time_zone
      get :some_action

      last_activity_at = User.last.last_activity_at

      last_activity_at.should be_present
      last_activity_at.to_s(:db).should >= now.to_s(:db)
      last_activity_at.to_s(:db).should <= (now+2).to_s(:db)
    end

    it "should log last IP address when logged in" do
      login_user
      get :some_action
      User.last.last_login_from_ip_address.should == "0.0.0.0"
    end

    it "should update nothing but activity fields" do
      original_user_name = User.last.username
      login_user
      get :some_action_making_a_non_persisted_change_to_the_user
      User.last.username.should == original_user_name
    end

    it "'current_users' should hold the user object when 1 user is logged in" do
      login_user
      get :some_action
      subject.current_users.size.should == 1
      subject.current_users[0].should == @user
    end

    it "'current_users' should show all current_users, whether they have logged out before or not." do
      user1 = create_new_user({:username => 'gizmo1', :email => "bla1@bla.com", :password => 'secret1'})
      login_user(user1)
      get :some_action
      clear_user_without_logout
      user2 = create_new_user({:username => 'gizmo2', :email => "bla2@bla.com", :password => 'secret2'})
      login_user(user2)
      get :some_action
      clear_user_without_logout
      user3 = create_new_user({:username => 'gizmo3', :email => "bla3@bla.com", :password => 'secret3'})
      login_user(user3)
      get :some_action
      subject.current_users.size.should == 3
      subject.current_users[0].should == user1
      subject.current_users[1].should == user2
      subject.current_users[2].should == user3
    end

    it "should not register login time if configured so" do
      sorcery_controller_property_set(:register_login_time, false)
      now = Time.now.in_time_zone
      login_user
      @user.last_login_at.should be_nil
    end

    it "should not register logout time if configured so" do
      sorcery_controller_property_set(:register_logout_time, false)
      now = Time.now.in_time_zone
      login_user
      logout_user
      @user.last_logout_at.should be_nil
    end

    it "should not register last activity time if configured so" do
      sorcery_controller_property_set(:register_last_activity_time, false)
      now = Time.now.in_time_zone
      login_user
      get :some_action
      @user.last_activity_at.should be_nil
    end

    it "should not register last IP address if configured so" do
      sorcery_controller_property_set(:register_last_ip_address, false)
      ip_address = "127.0.0.1"
      login_user
      get :some_action
      @user.last_activity_at.should be_nil
    end
  end
end