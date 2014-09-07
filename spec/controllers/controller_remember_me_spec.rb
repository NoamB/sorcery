require 'spec_helper'

describe SorceryController do

  let!(:user) { double('user', id: 42) }

  # ----------------- REMEMBER ME -----------------------
  context "with remember me features" do

    before(:all) do
      sorcery_reload!([:remember_me])
    end

    after(:each) do
      session = nil
      cookies = nil
    end

    before(:each) do
      allow(user).to receive(:remember_me_token)
      allow(user).to receive(:remember_me_token_expires_at)
      allow(user).to receive_message_chain(:sorcery_config, :remember_me_token_attribute_name).and_return(:remember_me_token)
      allow(user).to receive_message_chain(:sorcery_config, :remember_me_token_expires_at_attribute_name).and_return(:remember_me_token_expires_at)
    end

    it "sets cookie on remember_me!" do
      expect(User).to receive(:authenticate).with('bla@bla.com', 'secret').and_return(user)
      expect(user).to receive(:remember_me!)

      post :test_login_with_remember, :email => 'bla@bla.com', :password => 'secret'

      expect(cookies.signed["remember_me_token"]).to eq assigns[:current_user].remember_me_token
    end

    it "clears cookie on forget_me!" do
      cookies["remember_me_token"] == {:value => 'asd54234dsfsd43534', :expires => 3600}
      get :test_logout

      expect(cookies["remember_me_token"]).to be_nil
    end

    it "login(email,password,remember_me) logs user in and remembers" do
      expect(User).to receive(:authenticate).with('bla@bla.com', 'secret', '1').and_return(user)
      expect(user).to receive(:remember_me!)
      expect(user).to receive(:remember_me_token).and_return('abracadabra').twice

      post :test_login_with_remember_in_login, :email => 'bla@bla.com', :password => 'secret', :remember => "1"

      expect(cookies.signed["remember_me_token"]).not_to be_nil
      expect(cookies.signed["remember_me_token"]).to eq assigns[:user].remember_me_token
    end

    it "logout also calls forget_me!" do
      session[:user_id] = user.id.to_s
			expect(User.sorcery_adapter).to receive(:find_by_id).with(user.id.to_s).and_return(user)
      expect(user).to receive(:remember_me!)
      expect(user).to receive(:forget_me!)
      get :test_logout_with_remember

      expect(cookies["remember_me_token"]).to be_nil
    end

    it "logs user in from cookie" do
			session[:user_id] = user.id.to_s
			expect(User.sorcery_adapter).to receive(:find_by_id).with(user.id.to_s).and_return(user)
      expect(user).to receive(:remember_me!)
      expect(user).to receive(:remember_me_token).and_return('token').twice
      expect(user).to receive(:has_remember_me_token?) { true }

      subject.remember_me!
      subject.instance_eval do
        remove_instance_variable :@current_user
      end
      session[:user_id] = nil

      expect(User.sorcery_adapter).to receive(:find_by_remember_me_token).with('token').and_return(user)

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
      expect(user).to receive(:remember_me!)
      subject.auto_login(user, true)

      get :test_login_from_cookie

      expect(assigns[:current_user]).to eq user
      expect(cookies["remember_me_token"]).not_to be_nil
    end
  end
end
