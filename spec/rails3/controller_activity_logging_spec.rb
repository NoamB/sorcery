require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe ApplicationController do
  before(:all) do
    ActiveRecord::Migrator.migrate("#{Rails.root}/db/migrate/activity_logging")
  end
  
  after(:all) do
    ActiveRecord::Migrator.rollback("#{Rails.root}/db/migrate/activity_logging")
  end
  
  # ----------------- ACTIVITY LOGGING -----------------------
  describe ApplicationController, "with activity logging features" do
    before(:all) do
      plugin_model_configure([:activity_logging])
    end

    before(:each) do
      create_new_user
    end

    after(:each) do
      User.delete_all
    end

    it "should respond to 'logged_in_users'" do
      subject.should respond_to(:logged_in_users)
    end

    it "'logged_in_users' should be empty when no users are logged in" do
      subject.logged_in_users.size.should == 0
    end

    it "should log login time on login" do
      now = Time.now
      login_user
      @user.last_login.should_not be_nil
      @user.last_login.to_s(:db).should == now.to_s(:db)
    end

    it "should log logout time on logout" do
      login_user
      now = Time.now
      logout_user
      User.first.last_logout.should_not be_nil
      User.first.last_logout.to_s(:db).should == now.to_s(:db)
    end

    it "should log last activity time when logged in" do
      login_user
      now = Time.now
      get :some_action
      User.first.last_activity.to_s(:db).should == now.to_s(:db)
    end

    it "'logged_in_users' should hold the user object when 1 user is logged in" do
      login_user
      get :some_action
      subject.logged_in_users.size.should == 1
      subject.logged_in_users[0].should == @user
    end

    it "'logged_in_users' should show all logged_in_users, whether they have logged out before or not." do
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
      subject.logged_in_users.size.should == 3
      subject.logged_in_users[0].should == user1
      subject.logged_in_users[1].should == user2
      subject.logged_in_users[2].should == user3
    end
  end
end