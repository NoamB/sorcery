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
    let(:user) { double('user', id: 42) }

    before(:all) do
      sorcery_reload!
    end

    after(:each) do
      Sorcery::Controller::Config.reset!
      sorcery_reload!
      sorcery_controller_property_set(:user_class, User)
      sorcery_model_property_set(:username_attribute_names, [:email])
    end

    specify { should respond_to(:login) }

    specify { should respond_to(:logout) }

    specify { should respond_to(:logged_in?) }

    specify { should respond_to(:current_user) }

    specify { should respond_to(:require_login) }

    describe "#login" do

      context "when succeeds" do
        before do
          expect(User).to receive(:authenticate).with('bla@bla.com', 'secret').and_return(user)
          get :test_login, :email => 'bla@bla.com', :password => 'secret'
        end

        it "assigns user to @user variable" do
          expect(assigns[:user]).to eq user
        end

        it "writes user id in session" do
          expect(session[:user_id]).to eq user.id.to_s
        end

        it "sets csrf token in session" do
          expect(session[:_csrf_token]).not_to be_nil
        end

      end

      context "when fails" do
        before do
          expect(User).to receive(:authenticate).with('bla@bla.com', 'opensesame!').and_return(nil)
          get :test_login, :email => 'bla@bla.com', :password => 'opensesame!'
        end

        it "sets @user variable to nil" do
          expect(assigns[:user]).to be_nil
        end

        it "sets user_id in session to nil" do
          expect(session[:user_id]).to be_nil
        end
      end
    end

    describe "#logout" do
      it "clears the session" do
        cookies[:remember_me_token] = nil
        session[:user_id] = user.id.to_s
        expect(User.sorcery_adapter).to receive(:find_by_id).with("42") { user }
        get :test_logout

        expect(session[:user_id]).to be_nil
      end
    end

    describe "#logged_in?" do
      it "returns true when user is logged in" do
        session[:user_id] = user.id.to_s
        expect(User.sorcery_adapter).to receive(:find_by_id).with("42") { user }

        expect(subject.logged_in?).to be true
      end

      it "returns false when user is not logged in" do
        session[:user_id] = nil

        expect(subject.logged_in?).to be false
      end
    end

    describe "#current_user" do
      it "current_user returns the user instance if logged in" do
        session[:user_id] = user.id.to_s
        expect(User.sorcery_adapter).to receive(:find_by_id).once.with("42") { user }

        2.times { expect(subject.current_user).to eq user } # memoized!
      end

      it "current_user returns false if not logged in" do
        session[:user_id] = nil
        expect(User.sorcery_adapter).to_not receive(:find_by_id)

        2.times { expect(subject.current_user).to be_nil } # memoized!
      end
    end


    it "calls the configured 'not_authenticated_action' when authenticate before_action fails" do
      session[:user_id] = nil
      sorcery_controller_property_set(:not_authenticated_action, :test_not_authenticated_action)
      get :test_logout

      expect(response.body).to eq "test_not_authenticated_action"
    end

    it "require_login before_action saves the url that the user originally wanted" do
      get :some_action

      expect(session[:return_to_url]).to eq "http://test.host/some_action"
      expect(response).to redirect_to("http://test.host/")
    end

    it "require_login before_action does not save the url that the user originally wanted upon all non-get http methods" do
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

      expect(User).to receive(:first) { user }

      get :test_auto_login

      expect(assigns[:result]).to eq user
    end
  end

end
