require 'spec_helper'

require 'shared_examples/controller_oauth2_shared_examples'

describe SorceryController do
  before(:all) do
    ActiveRecord::Migrator.migrate("#{Rails.root}/db/migrate/external")
    User.reset_column_information

    sorcery_reload!([:external])
    set_external_property
  end

  after(:all) do
    ActiveRecord::Migrator.rollback("#{Rails.root}/db/migrate/external")
  end
  # ----------------- OAuth -----------------------
  describe SorceryController, "with OAuth features" do

    before(:each) do
      stub_all_oauth2_requests!
    end

    after(:each) do
      User.delete_all
      Authentication.delete_all
    end

    context "when callback_url begin with /" do
      before do
        sorcery_controller_external_property_set(:facebook, :callback_url, "/oauth/twitter/callback")
      end
      it "login_at redirects correctly" do
        create_new_user
        get :login_at_test2
        response.should be_a_redirect
        response.should redirect_to("https://graph.facebook.com/oauth/authorize?response_type=code&client_id=#{::Sorcery::Controller::Config.facebook.key}&redirect_uri=http%3A%2F%2Ftest.host%2Foauth%2Ftwitter%2Fcallback&scope=email%2Coffline_access&display=page&state")
      end
      it "logins with state" do
        create_new_user
        get :login_at_test_with_state
        response.should be_a_redirect
        response.should redirect_to("https://graph.facebook.com/oauth/authorize?response_type=code&client_id=#{::Sorcery::Controller::Config.facebook.key}&redirect_uri=http%3A%2F%2Ftest.host%2Foauth%2Ftwitter%2Fcallback&scope=email%2Coffline_access&display=page&state=bla")
      end
      after do
        sorcery_controller_external_property_set(:facebook, :callback_url, "http://blabla.com")
      end
    end

    #this test can never pass because of the previous test (the callback url can't change anymore)
=begin
    context "when callback_url begin with http://" do
      it "login_at redirects correctly" do
        create_new_user
        get :login_at_test2
        response.should be_a_redirect
        response.should redirect_to("https://graph.facebook.com/oauth/authorize?response_type=code&client_id=#{::Sorcery::Controller::Config.facebook.key}&redirect_uri=http%3A%2F%2Fblabla.com&scope=email%2Coffline_access&display=page&state")
      end
    end
=end
    it "'login_from' logins if user exists" do
      # dirty hack for rails 4
      @controller.stub(:register_last_activity_time_to_db)

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

    it "on successful login_from the user should be redirected to the url he originally wanted" do
      # dirty hack for rails 4
      @controller.stub(:register_last_activity_time_to_db)

      sorcery_model_property_set(:authentications_class, Authentication)
      create_new_external_user(:facebook)
      get :test_return_to_with_external2, {}, :return_to_url => "fuu"
      response.should redirect_to("fuu")
      flash[:notice].should == "Success!"
    end

  # provider: github
    it "login_at redirects correctly (github)" do
      create_new_user
      get :login_at_test3
      response.should be_a_redirect
      response.should redirect_to("https://github.com/login/oauth/authorize?response_type=code&client_id=#{::Sorcery::Controller::Config.github.key}&redirect_uri=http%3A%2F%2Fblabla.com&scope&display&state")
    end

    it "'login_from' logins if user exists (github)" do
      # dirty hack for rails 4
      @controller.stub(:register_last_activity_time_to_db)

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

    it "on successful login_from the user should be redirected to the url he originally wanted (github)" do
      # dirty hack for rails 4
      @controller.stub(:register_last_activity_time_to_db)

      sorcery_model_property_set(:authentications_class, Authentication)
      create_new_external_user(:github)
      get :test_return_to_with_external3, {}, :return_to_url => "fuu"
      response.should redirect_to("fuu")
      flash[:notice].should == "Success!"
    end

  # provider: google
    it "login_at redirects correctly (google)" do
      create_new_user
      get :login_at_test4
      response.should be_a_redirect
      response.should redirect_to("https://accounts.google.com/o/oauth2/auth?response_type=code&client_id=#{::Sorcery::Controller::Config.google.key}&redirect_uri=http%3A%2F%2Fblabla.com&scope=https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fuserinfo.email+https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fuserinfo.profile&display&state")
    end

    it "'login_from' logins if user exists (google)" do
      # dirty hack for rails 4
      @controller.stub(:register_last_activity_time_to_db)

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

    it "on successful login_from the user should be redirected to the url he originally wanted (google)" do
      # dirty hack for rails 4
      @controller.stub(:register_last_activity_time_to_db)

      sorcery_model_property_set(:authentications_class, Authentication)
      create_new_external_user(:google)
      get :test_return_to_with_external4, {}, :return_to_url => "fuu"
      response.should redirect_to("fuu")
      flash[:notice].should == "Success!"
    end

  # provider: liveid
    it "login_at redirects correctly (liveid)" do
      create_new_user
      get :login_at_test5
      response.should be_a_redirect
      response.should redirect_to("https://oauth.live.com/authorize?response_type=code&client_id=#{::Sorcery::Controller::Config.liveid.key}&redirect_uri=http%3A%2F%2Fblabla.com&scope=wl.basic+wl.emails+wl.offline_access&display&state")
    end

    it "'login_from' logins if user exists (liveid)" do
      # dirty hack for rails 4
      @controller.stub(:register_last_activity_time_to_db)

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

    it "on successful login_from the user should be redirected to the url he originally wanted (liveid)" do
      # dirty hack for rails 4
      @controller.stub(:register_last_activity_time_to_db)

      sorcery_model_property_set(:authentications_class, Authentication)
      create_new_external_user(:liveid)
      get :test_return_to_with_external5, {}, :return_to_url => "fuu"
      response.should redirect_to("fuu")
      flash[:notice].should == "Success!"
    end

  end


  describe SorceryController do
    it_behaves_like "oauth2_controller"
  end

  describe SorceryController, "OAuth with User Activation features" do
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

  describe SorceryController, "OAuth with user activation features"  do
    before(:all) do
      ActiveRecord::Migrator.migrate("#{Rails.root}/db/migrate/external")
      ActiveRecord::Migrator.migrate("#{Rails.root}/db/migrate/activity_logging")
      User.reset_column_information
      sorcery_reload!([:activity_logging, :external])
    end

    after(:all) do
      ActiveRecord::Migrator.rollback("#{Rails.root}/db/migrate/external")
      ActiveRecord::Migrator.rollback("#{Rails.root}/db/migrate/activity_logging")
    end

    %w(facebook github google liveid).each.with_index(2) do |provider, index|
      context "when #{provider}" do
        before(:each) do
          User.delete_all
          Authentication.delete_all
          sorcery_controller_property_set(:register_login_time, true)
          stub_all_oauth2_requests!
          sorcery_model_property_set(:authentications_class, Authentication)
          create_new_external_user(provider.to_sym)
        end

        it "should register login time" do
          now = Time.now.in_time_zone
          get "test_login_from#{index}".to_sym
          User.last.last_login_at.should_not be_nil
          User.last.last_login_at.to_s(:db).should >= now.to_s(:db)
          User.last.last_login_at.to_s(:db).should <= (now+2).to_s(:db)
        end

        it "should not register login time if configured so" do
          sorcery_controller_property_set(:register_login_time, false)
          now = Time.now.in_time_zone
          get "test_login_from#{index}".to_sym
          User.last.last_login_at.should be_nil
        end
      end
    end
  end

  describe SorceryController, "OAuth with session timeout features" do
    before(:all) do
      ActiveRecord::Migrator.migrate("#{Rails.root}/db/migrate/external")
      User.reset_column_information
      sorcery_reload!([:session_timeout, :external])
    end

    after(:all) do
      ActiveRecord::Migrator.rollback("#{Rails.root}/db/migrate/external")
    end

    %w(facebook github google liveid).each.with_index(2) do |provider, index|
      context "when #{provider}" do
        before(:each) do
          User.delete_all
          Authentication.delete_all
          sorcery_model_property_set(:authentications_class, Authentication)
          sorcery_controller_property_set(:session_timeout,0.5)
          stub_all_oauth2_requests!
          create_new_external_user(provider.to_sym)
        end

        after(:each) do
          Timecop.return
        end

        it "should not reset session before session timeout" do
          get "test_login_from#{index}".to_sym
          session[:user_id].should_not be_nil
          flash[:notice].should == "Success!"
        end

        it "should reset session after session timeout" do
          get "test_login_from#{index}".to_sym
          Timecop.travel(Time.now.in_time_zone+0.6)
          get :test_should_be_logged_in
          session[:user_id].should be_nil
          response.should be_a_redirect
        end
      end
    end
  end

  def stub_all_oauth2_requests!
    auth_code       = OAuth2::Strategy::AuthCode.any_instance
    access_token    = double(OAuth2::AccessToken)
    access_token.stub(:token_param=)
    response        = double(OAuth2::Response)
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

  def set_external_property
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
end
