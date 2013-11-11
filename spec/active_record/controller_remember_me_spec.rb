require 'spec_helper'

describe SorceryController do

  # ----------------- REMEMBER ME -----------------------
  describe SorceryController, "with remember me features" do

    before(:all) do
      ActiveRecord::Migrator.migrate("#{Rails.root}/db/migrate/remember_me")
      User.reset_column_information
      sorcery_reload!([:remember_me])
    end

    before(:each) do
      create_new_user
    end

    after(:all) do
      ActiveRecord::Migrator.rollback("#{Rails.root}/db/migrate/remember_me")
    end

    after(:each) do
      session = nil
      cookies = nil
      User.delete_all
    end

    it "should set cookie on remember_me!" do
      post :test_login_with_remember, :email => 'bla@bla.com', :password => 'secret'
      # @request.cookies.merge!(cookies)
      # cookies = ActionDispatch::Cookies::CookieJar.build(@request)
      cookies.signed["remember_me_token"].should == assigns[:current_user].remember_me_token
    end

    it "should clear cookie on forget_me!" do
      cookies["remember_me_token"] == {:value => 'asd54234dsfsd43534', :expires => 3600}
      get :test_logout
      cookies["remember_me_token"].should be_nil
    end

    it "login(email,password,remember_me) should login and remember" do
      post :test_login_with_remember_in_login, :email => 'bla@bla.com', :password => 'secret', :remember => "1"
      # cookies = ActionDispatch::Cookies::CookieJar.build(@request)
      cookies.signed["remember_me_token"].should_not be_nil
      cookies.signed["remember_me_token"].should == assigns[:user].remember_me_token
    end

    it "logout should also forget_me!" do
      session[:user_id] = @user.id
      get :test_logout_with_remember
      cookies["remember_me_token"].should be_nil
    end

    it "should login_from_cookie" do
      session[:user_id] = @user.id
      subject.remember_me!
      subject.instance_eval do
        @current_user = nil
      end
      session[:user_id] = nil
      get :test_login_from_cookie
      assigns[:current_user].should == @user
    end

    it "should not remember_me! when not asked to, even if third parameter is used" do
      post :test_login_with_remember_in_login, :email => 'bla@bla.com', :password => 'secret', :remember => "0"
      cookies["remember_me_token"].should be_nil
    end

    it "should not remember_me! when not asked to" do
      post :test_login, :email => 'bla@bla.com', :password => 'secret'
      cookies["remember_me_token"].should be_nil
    end

    # --- login_user(user) ---
    specify { should respond_to(:auto_login) }

    it "auto_login(user) should login a user instance without remembering" do
      create_new_user
      session[:user_id] = nil
      subject.auto_login(@user)
      get :test_login_from_cookie
      assigns[:current_user].should == @user
      cookies["remember_me_token"].should be_nil
    end

    it "auto_login(user, true) should login a user instance with remembering" do
      create_new_user
      session[:user_id] = nil
      subject.auto_login(@user, true)
      get :test_login_from_cookie
      assigns[:current_user].should == @user
      cookies["remember_me_token"].should_not be_nil
    end
  end
end