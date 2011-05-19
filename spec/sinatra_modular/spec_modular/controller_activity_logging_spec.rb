require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Modular do
  before(:all) do
    ActiveRecord::Migrator.migrate("#{APP_ROOT}/db/migrate/activity_logging")
  end
  
  after(:all) do
    ActiveRecord::Migrator.rollback("#{APP_ROOT}/db/migrate/activity_logging")
  end
  
  # ----------------- ACTIVITY LOGGING -----------------------
  describe Modular, "with activity logging features" do
    before(:all) do
      sorcery_reload!([:activity_logging])
      clear_cookies
    end

    before(:each) do
      create_new_user
    end

    after(:each) do
      User.delete_all
    end

    it "should respond to 'current_users'" do
      get_sinatra_app(subject).should respond_to(:current_users)
    end

    it "'current_users' should be empty when no users are logged in" do
      get_sinatra_app(subject).current_users.size.should == 0
    end

    it "should log login time on login" do
      now = Time.now.utc
      get "/test_login", :username => 'gizmo', :password => 'secret'
      User.first.last_login_at.should_not be_nil
      User.first.last_login_at.to_s(:db).should >= now.to_s(:db)
      User.first.last_login_at.to_s(:db).should <= (now+2).to_s(:db)
    end

    it "should log logout time on logout" do
      get "/test_login", :username => 'gizmo', :password => 'secret'
      now = Time.now.utc
      get "/test_logout"
      User.first.last_logout_at.should_not be_nil
      User.first.last_logout_at.to_s(:db).should >= now.to_s(:db)
      User.first.last_logout_at.to_s(:db).should <= (now+2).to_s(:db)
    end

    it "should log last activity time when logged in" do
      get "/test_login", :username => 'gizmo', :password => 'secret'
      now = Time.now.utc
      get "/some_action"
      User.first.last_activity_at.to_s.should >= now.to_s(:db)
      User.first.last_activity_at.to_s.should <= (now+2).to_s(:db)
    end

    it "'current_users' should hold the user object when 1 user is logged in" do
      get "/test_login", :username => 'gizmo', :password => 'secret'
      get "/some_action"
      get_sinatra_app(subject).current_users.size.should == 1
      get_sinatra_app(subject).current_users[0].should == @user
    end

    it "'current_users' should show all current_users, whether they have logged out before or not." do
      user1 = create_new_user({:username => 'gizmo1', :email => "bla1@bla.com", :password => 'secret1'})
      get "/test_login", :username => 'gizmo1', :password => 'secret1'
      get "/some_action"
      clear_user_without_logout
      user2 = create_new_user({:username => 'gizmo2', :email => "bla2@bla.com", :password => 'secret2'})
      get "/test_login", :username => 'gizmo2', :password => 'secret2'
      get "/some_action"
      clear_user_without_logout
      user3 = create_new_user({:username => 'gizmo3', :email => "bla3@bla.com", :password => 'secret3'})
      get "/test_login", :username => 'gizmo3', :password => 'secret3'
      get "/some_action"
      get_sinatra_app(subject).current_users.size.should == 3
      get_sinatra_app(subject).current_users[0].should == user1
      get_sinatra_app(subject).current_users[1].should == user2
      get_sinatra_app(subject).current_users[2].should == user3
    end
  end
end