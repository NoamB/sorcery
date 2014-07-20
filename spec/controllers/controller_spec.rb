require 'spec_helper'

describe SorceryController do
  describe "plugin configuration" do
    before(:all) do
      sorcery_reload!
    end

    after(:each) do
      Sorcery::Controller::Config.reset!
      sorcery_reload!
    end

    it "enables configuration option 'user_class'" do
      sorcery_controller_property_set(:user_class, "TestUser")

      expect(Sorcery::Controller::Config.user_class).to eq "TestUser"
    end

    it "enables configuration option 'not_authenticated_action'" do
      sorcery_controller_property_set(:not_authenticated_action, :my_action)

      expect(Sorcery::Controller::Config.not_authenticated_action).to eq :my_action
    end

  end

  # ----------------- PLUGIN ACTIVATED -----------------------
  context "when activated with sorcery" do
    let!(:user) { create_new_user }

    before(:all) do
      sorcery_reload!
      User.sorcery_adapter.delete_all
    end

    after(:each) do
      Sorcery::Controller::Config.reset!
      sorcery_reload!
      User.sorcery_adapter.delete_all
      sorcery_controller_property_set(:user_class, User)
      sorcery_model_property_set(:username_attribute_names, [:email])
    end

    specify { should respond_to(:login) }

    specify { should respond_to(:logout) }

    specify { should respond_to(:logged_in?) }

    specify { should respond_to(:current_user) }

    it "login(username,password) returns the user when success and set the session with user.id" do
      get :test_login, :email => 'bla@bla.com', :password => 'secret'

      expect(assigns[:user]).to eq user
      expect(session[:user_id]).to eq user.id
    end

    it "login(email,password) returns the user when success and set the session with user.id" do
      get :test_login, :email => 'bla@bla.com', :password => 'secret'

      expect(assigns[:user]).to eq user
      expect(session[:user_id]).to eq user.id
    end

    it "login(username,password) returns nil and not set the session when failure" do
      get :test_login, :email => 'bla@bla.com', :password => 'opensesame!'

      expect(assigns[:user]).to be_nil
      expect(session[:user_id]).to be_nil
    end

    it "login(email,password) returns the user when success and set the session with the _csrf_token" do
      get :test_login, :email => 'bla@bla.com', :password => 'secret'

      expect(session[:_csrf_token]).not_to be_nil
    end

    it "login(username,password) returns nil and not set the session when upper case username" do
      skip('DM Adapter dependant') if SORCERY_ORM == :data_mapper
      get :test_login, :email => 'BLA@BLA.COM', :password => 'secret'

      expect(assigns[:user]).to be_nil
      expect(session[:user_id]).to be_nil
    end

    it "login(username,password) returns the user and set the session with user.id when upper case username and config is downcase before authenticating" do
      sorcery_model_property_set(:downcase_username_before_authenticating, true)
      get :test_login, :email => 'BLA@BLA.COM', :password => 'secret'

      expect(assigns[:user]).to eq user
      expect(session[:user_id]).to eq user.id
    end

    it "login(username,password) returns nil and not set the session when user was created with upper case username, config is default, and log in username is lower case" do
      skip('DM Adapter dependant') if SORCERY_ORM == :data_mapper
      create_new_user({:username => "", :email => "BLA1@BLA.COM", :password => 'secret1'})
      get :test_login, :email => 'bla1@bla.com', :password => 'secret1'

      expect(assigns[:user]).to be_nil
      expect(session[:user_id]).to be_nil
    end

    it "login(username,password) returns the user and set the session with user.id when user was created with upper case username and config is downcase before authenticating" do
      skip('DM Adapter dependant') if SORCERY_ORM == :data_mapper
      sorcery_model_property_set(:downcase_username_before_authenticating, true)
      new_user = create_new_user({:username => "", :email => "BLA1@BLA.COM", :password => 'secret1'})
      get :test_login, :email => 'bla1@bla.com', :password => 'secret1'

      expect(assigns[:user]).to eq new_user
      expect(session[:user_id]).to eq new_user.id
    end

    it "logout clears the session" do
      cookies[:remember_me_token] = nil
      session[:user_id] = user.id
      get :test_logout

      expect(session[:user_id]).to be_nil
    end

    it "logged_in? returns true if logged in" do
      session[:user_id] = user.id

      expect(subject.logged_in?).to be true
    end

    it "logged_in? returns false if not logged in" do
      session[:user_id] = nil

      expect(subject.logged_in?).to be false
    end

    it "current_user returns the user instance if logged in" do
      create_new_user
      session[:user_id] = user.id

      2.times { expect(subject.current_user).to eq user } # memoized!
    end

    it "current_user returns false if not logged in" do
      session[:user_id] = nil

      2.times { expect(subject.current_user).to be_nil } # memoized!
    end

    specify { should respond_to(:require_login) }

    it "calls the configured 'not_authenticated_action' when authenticate before_filter fails" do
      session[:user_id] = nil
      sorcery_controller_property_set(:not_authenticated_action, :test_not_authenticated_action)
      get :test_logout

      expect(response.body).to eq "test_not_authenticated_action"
    end

    it "require_login before_filter saves the url that the user originally wanted" do
      get :some_action

      expect(session[:return_to_url]).to eq "http://test.host/some_action"
      expect(response).to redirect_to("http://test.host/")
    end

    it "require_login before_filter does not save the url that the user originally wanted upon all non-get http methods" do
      [:post, :put, :delete].each do |m|
        self.send(m, :some_action)

        expect(session[:return_to_url]).to be_nil
      end
    end

    it "on successful login the user is redirected to the url he originally wanted" do
      session[:return_to_url] = "http://test.host/some_action"
      post :test_return_to, :email => 'bla@bla.com', :password => 'secret'

      expect(response).to redirect_to("http://test.host/some_action")
      expect(flash[:notice]).to eq "haha!"
    end


    # --- auto_login(user) ---
    specify { should respond_to(:auto_login) }

    it "auto_login(user) los in a user instance" do
      session[:user_id] = nil
      subject.auto_login(user)

      expect(subject.logged_in?).to be true
    end

    it "auto_login(user) works even if current_user was already set to false" do
      get :test_logout

      expect(session[:user_id]).to be_nil
      expect(subject.current_user).to be_nil

      get :test_auto_login

      expect(assigns[:result]).to eq User.first
    end
  end

end
