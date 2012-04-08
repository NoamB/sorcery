require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/../../shared_examples/controller_oauth2_shared_examples')

def stub_all_oauth2_requests!
  auth_code       = OAuth2::Strategy::AuthCode.any_instance
  access_token    = mock(OAuth2::AccessToken)
  access_token.stub(:token_param=)
  response        = mock(OAuth2::Response)
  response.stub(:body).and_return({
    "id"=>"123",
    "name"=>"Noam Ben Ari",
    "first_name"=>"Noam",
    "last_name"=>"Ben Ari",
    "link"=>"http://www.facebook.com/nbenari1",
    "hometown"=>{"id"=>"110619208966868", "name"=>"Haifa, Israel"},
    "location"=>{"id"=>"106906559341067", "name"=>"Pardes Hanah, Hefa, Israel"},
    "bio"=>"I'm a new daddy, and enjoying it!",
    "gender"=>"male",
    "email"=>"nbenari@gmail.com",
    "timezone"=>2,
    "locale"=>"en_US",
    "languages"=>[{"id"=>"108405449189952", "name"=>"Hebrew"}, {"id"=>"106059522759137", "name"=>"English"}, {"id"=>"112624162082677", "name"=>"Russian"}],
    "verified"=>true,
    "updated_time"=>"2011-02-16T20:59:38+0000"}.to_json)
  access_token.stub(:get).and_return(response)
  auth_code.stub(:get_token).and_return(access_token)
end

describe ApplicationController do
  before(:all) do
    ActiveRecord::Migrator.migrate("#{Rails.root}/db/migrate/external")
    sorcery_reload!([:external])
    sorcery_controller_property_set(:external_providers, [:facebook, :github, :google, :liveid])
    sorcery_controller_external_property_set(:facebook, :key, "eYVNBjBDi33aa9GkA3w")
    sorcery_controller_external_property_set(:facebook, :secret, "XpbeSdCoaKSmQGSeokz5qcUATClRW5u08QWNfv71N8")
    sorcery_controller_external_property_set(:facebook, :callback_url, "http://blabla.com")
    sorcery_controller_external_property_set(:github, :key, "eYVNBjBDi33aa9GkA3w")
    sorcery_controller_external_property_set(:github, :secret, "XpbeSdCoaKSmQGSeokz5qcUATClRW5u08QWNfv71N8")
    sorcery_controller_external_property_set(:github, :callback_url, "http://blabla.com")
    sorcery_controller_external_property_set(:google, :key, "eYVNBjBDi33aa9GkA3w")
    sorcery_controller_external_property_set(:google, :secret, "XpbeSdCoaKSmQGSeokz5qcUATClRW5u08QWNfv71N8")
    sorcery_controller_external_property_set(:google, :callback_url, "http://blabla.com")
    sorcery_controller_external_property_set(:liveid, :key, "eYVNBjBDi33aa9GkA3w")
    sorcery_controller_external_property_set(:liveid, :secret, "XpbeSdCoaKSmQGSeokz5qcUATClRW5u08QWNfv71N8")
    sorcery_controller_external_property_set(:liveid, :callback_url, "http://blabla.com")
  end

  after(:all) do
    ActiveRecord::Migrator.rollback("#{Rails.root}/db/migrate/external")
  end
  # ----------------- OAuth -----------------------
  describe ApplicationController, "with OAuth features" do

    before(:each) do
      stub_all_oauth2_requests!
    end

    after(:each) do
      User.delete_all
      Authentication.delete_all
    end

    it "login_at redirects correctly" do
      create_new_user
      get :login_at_test2
      response.should be_a_redirect
      response.should redirect_to("https://graph.facebook.com/oauth/authorize?response_type=code&client_id=#{::Sorcery::Controller::Config.facebook.key}&redirect_uri=http%3A%2F%2Fblabla.com&scope=email%2Coffline_access&display=page")
    end

    it "'login_from' logins if user exists" do
      sorcery_model_property_set(:authentications_class, Authentication)
      create_new_external_user(:facebook)
      get :test_login_from2
      flash[:notice].should == "Success!"
    end

    it "'login_from' fails if user doesn't exist" do
      sorcery_model_property_set(:authentications_class, Authentication)
      create_new_user
      get :test_login_from2
      flash[:alert].should == "Failed!"
    end

  # provider: github
    it "login_at redirects correctly (github)" do
      create_new_user
      get :login_at_test3
      response.should be_a_redirect
      response.should redirect_to("https://github.com/login/oauth/authorize?response_type=code&client_id=#{::Sorcery::Controller::Config.github.key}&redirect_uri=http%3A%2F%2Fblabla.com&scope=&display=")
    end

    it "'login_from' logins if user exists (github)" do
      sorcery_model_property_set(:authentications_class, Authentication)
      create_new_external_user(:github)
      get :test_login_from3
      flash[:notice].should == "Success!"
    end

    it "'login_from' fails if user doesn't exist (github)" do
      sorcery_model_property_set(:authentications_class, Authentication)
      create_new_user
      get :test_login_from3
      flash[:alert].should == "Failed!"
    end

  # provider: google
    it "login_at redirects correctly (google)" do
      create_new_user
      get :login_at_test4
      response.should be_a_redirect
      response.should redirect_to("https://accounts.google.com/o/oauth2/auth?response_type=code&client_id=#{::Sorcery::Controller::Config.google.key}&redirect_uri=http%3A%2F%2Fblabla.com&scope=https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fuserinfo.email%20https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fuserinfo.profile&display=")
    end

    it "'login_from' logins if user exists (google)" do
      sorcery_model_property_set(:authentications_class, Authentication)
      create_new_external_user(:google)
      get :test_login_from4
      flash[:notice].should == "Success!"
    end

    it "'login_from' fails if user doesn't exist (google)" do
      sorcery_model_property_set(:authentications_class, Authentication)
      create_new_user
      get :test_login_from4
      flash[:alert].should == "Failed!"
    end

  # provider: liveid
    it "login_at redirects correctly (liveid)" do
      create_new_user
      get :login_at_test5
      response.should be_a_redirect
      response.should redirect_to("https://oauth.live.com/authorize?response_type=code&client_id=#{::Sorcery::Controller::Config.liveid.key}&redirect_uri=http%3A%2F%2Fblabla.com&scope=wl.basic%20wl.emails%20wl.offline_access&display=")
    end

    it "'login_from' logins if user exists (liveid)" do
      sorcery_model_property_set(:authentications_class, Authentication)
      create_new_external_user(:liveid)
      get :test_login_from5
      flash[:notice].should == "Success!"
    end

    it "'login_from' fails if user doesn't exist (liveid)" do
      sorcery_model_property_set(:authentications_class, Authentication)
      create_new_user
      get :test_login_from5
      flash[:alert].should == "Failed!"
    end

  end


  describe ApplicationController do
    it_behaves_like "oauth2_controller"
  end

  describe ApplicationController, "OAuth with User Activation features" do
    before(:all) do
      ActiveRecord::Migrator.migrate("#{Rails.root}/db/migrate/activation")
      sorcery_reload!([:user_activation,:external], :user_activation_mailer => ::SorceryMailer)
      sorcery_controller_property_set(:external_providers, [:facebook, :github, :google, :liveid])
      sorcery_controller_external_property_set(:facebook, :key, "eYVNBjBDi33aa9GkA3w")
      sorcery_controller_external_property_set(:facebook, :secret, "XpbeSdCoaKSmQGSeokz5qcUATClRW5u08QWNfv71N8")
      sorcery_controller_external_property_set(:facebook, :callback_url, "http://blabla.com")
      sorcery_controller_external_property_set(:github, :key, "eYVNBjBDi33aa9GkA3w")
      sorcery_controller_external_property_set(:github, :secret, "XpbeSdCoaKSmQGSeokz5qcUATClRW5u08QWNfv71N8")
      sorcery_controller_external_property_set(:github, :callback_url, "http://blabla.com")
      sorcery_controller_external_property_set(:google, :key, "eYVNBjBDi33aa9GkA3w")
      sorcery_controller_external_property_set(:google, :secret, "XpbeSdCoaKSmQGSeokz5qcUATClRW5u08QWNfv71N8")
      sorcery_controller_external_property_set(:google, :callback_url, "http://blabla.com")
      sorcery_controller_external_property_set(:liveid, :key, "eYVNBjBDi33aa9GkA3w")
      sorcery_controller_external_property_set(:liveid, :secret, "XpbeSdCoaKSmQGSeokz5qcUATClRW5u08QWNfv71N8")
      sorcery_controller_external_property_set(:liveid, :callback_url, "http://blabla.com")

    end

    after(:all) do
      ActiveRecord::Migrator.rollback("#{Rails.root}/db/migrate/activation")
    end

    after(:each) do
      User.delete_all
    end

    it "should not send activation email to external users" do
      old_size = ActionMailer::Base.deliveries.size
      create_new_external_user(:facebook)
      ActionMailer::Base.deliveries.size.should == old_size
    end

    it "should not send external users an activation success email" do
      sorcery_model_property_set(:activation_success_email_method_name, nil)
      create_new_external_user(:facebook)
      old_size = ActionMailer::Base.deliveries.size
      @user.activate!
      ActionMailer::Base.deliveries.size.should == old_size
    end

  # provider: github
    it "should not send activation email to external users (github)" do
      old_size = ActionMailer::Base.deliveries.size
      create_new_external_user(:github)
      ActionMailer::Base.deliveries.size.should == old_size
    end

    it "should not send external users an activation success email (github)" do
      sorcery_model_property_set(:activation_success_email_method_name, nil)
      create_new_external_user(:github)
      old_size = ActionMailer::Base.deliveries.size
      @user.activate!
      ActionMailer::Base.deliveries.size.should == old_size
    end

  # provider: google
    it "should not send activation email to external users (google)" do
      old_size = ActionMailer::Base.deliveries.size
      create_new_external_user(:google)
      ActionMailer::Base.deliveries.size.should == old_size
    end

    it "should not send external users an activation success email (google)" do
      sorcery_model_property_set(:activation_success_email_method_name, nil)
      create_new_external_user(:google)
      old_size = ActionMailer::Base.deliveries.size
      @user.activate!
      ActionMailer::Base.deliveries.size.should == old_size
    end

  # provider: liveid
    it "should not send activation email to external users (liveid)" do
      old_size = ActionMailer::Base.deliveries.size
      create_new_external_user(:liveid)
      ActionMailer::Base.deliveries.size.should == old_size
    end

    it "should not send external users an activation success email (liveid)" do
      sorcery_model_property_set(:activation_success_email_method_name, nil)
      create_new_external_user(:liveid)
      old_size = ActionMailer::Base.deliveries.size
      @user.activate!
      ActionMailer::Base.deliveries.size.should == old_size
    end
  end
end
