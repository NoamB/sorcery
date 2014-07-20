require 'spec_helper'

describe SorceryController do

  let!(:user) { create_new_user }

  # ----------------- REMEMBER ME -----------------------
  context "with remember me features" do

    before(:all) do
      if SORCERY_ORM == :active_record
        ActiveRecord::Migrator.migrate("#{Rails.root}/db/migrate/remember_me")
        User.reset_column_information
      end

      sorcery_reload!([:remember_me])
    end

    after(:all) do
      if SORCERY_ORM == :active_record
        ActiveRecord::Migrator.rollback("#{Rails.root}/db/migrate/remember_me")
      end
    end

    after(:each) do
      session = nil
      cookies = nil
      User.sorcery_adapter.delete_all
    end

    it "sets cookie on remember_me!" do
      post :test_login_with_remember, :email => 'bla@bla.com', :password => 'secret'

      expect(cookies.signed["remember_me_token"]).to eq assigns[:current_user].remember_me_token
    end

    it "clears cookie on forget_me!" do
      cookies["remember_me_token"] == {:value => 'asd54234dsfsd43534', :expires => 3600}
      get :test_logout

      expect(cookies["remember_me_token"]).to be_nil
    end

    it "login(email,password,remember_me) logs user in and remembers" do
      post :test_login_with_remember_in_login, :email => 'bla@bla.com', :password => 'secret', :remember => "1"

      expect(cookies.signed["remember_me_token"]).not_to be_nil
      expect(cookies.signed["remember_me_token"]).to eq assigns[:user].remember_me_token
    end

    it "logout also calls forget_me!" do
      session[:user_id] = user.id
      get :test_logout_with_remember

      expect(cookies["remember_me_token"]).to be_nil
    end

    it "logs user in from cookie" do
      session[:user_id] = user.id
      subject.remember_me!
      subject.instance_eval do
        remove_instance_variable :@current_user
      end
      session[:user_id] = nil
      get :test_login_from_cookie

      expect(assigns[:current_user]).to eq user
    end

    it "doest not remember_me! when not asked to, even if third parameter is used" do
      post :test_login_with_remember_in_login, :email => 'bla@bla.com', :password => 'secret', :remember => "0"

      expect(cookies["remember_me_token"]).to be_nil
    end

    it "doest not remember_me! when not asked to" do
      post :test_login, :email => 'bla@bla.com', :password => 'secret'
      expect(cookies["remember_me_token"]).to be_nil
    end

    # --- login_user(user) ---
    specify { expect(@controller).to respond_to :auto_login }

    it "auto_login(user) logs in an user instance without remembering" do
      session[:user_id] = nil
      subject.auto_login(user)
      get :test_login_from_cookie

      expect(assigns[:current_user]).to eq user
      expect(cookies["remember_me_token"]).to be_nil
    end

    it "auto_login(user, true) logs in an user instance with remembering" do
      session[:user_id] = nil
      subject.auto_login(user, true)
      get :test_login_from_cookie

      expect(assigns[:current_user]).to eq user
      expect(cookies["remember_me_token"]).not_to be_nil
    end
  end
end
