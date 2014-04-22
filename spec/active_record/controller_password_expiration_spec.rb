require 'spec_helper'

describe SorceryController do
  before(:all) do
    ActiveRecord::Migrator.migrate("#{Rails.root}/db/migrate/password_expiration")
    User.reset_column_information
  end

  after(:all) do
    ActiveRecord::Migrator.rollback("#{Rails.root}/db/migrate/password_expiration")
  end

  # ----------------- PASSWORD EXPIRATION -----------------------
  describe SorceryController, 'with password expiration features' do
    before(:all) do
      sorcery_reload!([:password_expiration])
    end

    before(:each) do
      create_new_user
      @user.need_password_changed!
      login_user
    end

    after(:each) do
      User.delete_all
    end

    it "should enable configuration option 'change_password_action'" do
      sorcery_controller_property_set(:change_password_action, :my_action)
      expect(Sorcery::Controller::Config.change_password_action).to eq :my_action

      Sorcery::Controller::Config.reset!
      sorcery_reload!([:password_expiration])
    end

    specify { should respond_to(:require_valid_password) }

    it "should call the configured 'change_password_action' when valid_password before_filter fails" do
      sorcery_controller_property_set(:change_password_action, :test_update_password_action)

      get :test_password_expiration

      expect(response.body).to eq 'test_update_password_action'

      Sorcery::Controller::Config.reset!
      sorcery_reload!([:password_expiration])
    end

    it 'require_valid_password before_filter should save the url that the user originally wanted' do
      get :test_password_expiration

      expect(session[:return_to_url]).to eq 'http://test.host/test_password_expiration'
      expect(response).to redirect_to('http://test.host/')
    end

    it 'require_login before_filter should not save the url that the user originally wanted upon all non-get http methods' do
      [:post, :put, :delete].each do |m|
        self.send(m, :test_password_expiration)
        expect(session[:return_to_url]).to be_nil
      end
    end

    it 'on successful login the user should be redirected to the url he originally wanted' do
      sorcery_controller_property_set(:change_password_action, :test_update_password_action)

      get :test_password_expiration

      expect(response.body).to eq 'test_update_password_action'

      post :test_update_password_action,
        :user => { :current_password => 'secret', :password => 'new_secret', :password_confirmation => 'new_secret' }

      expect(response).to redirect_to('http://test.host/test_password_expiration')
      expect(flash[:notice]).to eq 'password updated!'

      Sorcery::Controller::Config.reset!
      sorcery_reload!([:password_expiration])
    end
  end
end
