require 'spec_helper'

# require 'shared_examples/controller_oauth2_shared_examples'

describe SorceryController, :active_record => true do
  before(:all) do
    if SORCERY_ORM == :active_record
      ActiveRecord::Migrator.migrate("#{Rails.root}/db/migrate/external")
      User.reset_column_information
    end

    sorcery_reload!([:external])
    set_external_property
  end

  after(:all) do
    if SORCERY_ORM == :active_record
      ActiveRecord::Migrator.rollback("#{Rails.root}/db/migrate/external")
    end
  end

  describe 'using create_from' do
    before(:each) do
      stub_all_oauth2_requests!
      User.sorcery_adapter.delete_all
      Authentication.sorcery_adapter.delete_all
    end

    it 'creates a new user' do
      sorcery_model_property_set(:authentications_class, Authentication)
      sorcery_controller_external_property_set(:facebook, :user_info_mapping, { username: 'name' })

      expect { get :test_create_from_provider, provider: 'facebook' }.to change { User.count }.by 1
      expect(User.first.username).to eq 'Noam Ben Ari'
    end

    it 'supports nested attributes' do
      sorcery_model_property_set(:authentications_class, Authentication)
      sorcery_controller_external_property_set(:facebook, :user_info_mapping, { username: 'hometown/name' })

      expect { get :test_create_from_provider, provider: 'facebook' }.to change { User.count }.by(1)
      expect(User.first.username).to eq 'Haifa, Israel'
    end

    it 'does not crash on missing nested attributes' do
      sorcery_model_property_set(:authentications_class, Authentication)
      sorcery_controller_external_property_set(:facebook, :user_info_mapping, { username: 'name', created_at: 'does/not/exist' })

      expect { get :test_create_from_provider, provider: 'facebook' }.to change { User.count }.by 1
      expect(User.first.username).to eq 'Noam Ben Ari'
      expect(User.first.created_at).not_to be_nil
    end

    describe 'with a block' do

      before(:each) do
        user = User.new(username: 'Noam Ben Ari')
        user.save!(validate: false)
        user.authentications.create(provider: 'twitter', uid: '456')
      end

      it 'does not create user' do
        sorcery_model_property_set(:authentications_class, Authentication)
        sorcery_controller_external_property_set(:facebook, :user_info_mapping, { username: 'name' })

        # test_create_from_provider_with_block in controller will check for uniqueness of username
        expect { get :test_create_from_provider_with_block, provider: 'facebook' }.not_to change { User.count }
      end

    end
  end

  # ----------------- OAuth -----------------------
  context "with OAuth features" do

    before(:each) do
      stub_all_oauth2_requests!
    end

    after(:each) do
      User.sorcery_adapter.delete_all
      Authentication.sorcery_adapter.delete_all
    end

    context "when callback_url begin with /" do
      before do
        sorcery_controller_external_property_set(:facebook, :callback_url, "/oauth/twitter/callback")
      end
      it "login_at redirects correctly" do
        create_new_user
        get :login_at_test_facebook
        expect(response).to be_a_redirect
        expect(response).to redirect_to("https://graph.facebook.com/oauth/authorize?client_id=#{::Sorcery::Controller::Config.facebook.key}&display=page&redirect_uri=http%3A%2F%2Ftest.host%2Foauth%2Ftwitter%2Fcallback&response_type=code&scope=email%2Coffline_access&state=")
      end
      it "logins with state" do
        create_new_user
        get :login_at_test_with_state
        expect(response).to be_a_redirect
        expect(response).to redirect_to("https://graph.facebook.com/oauth/authorize?client_id=#{::Sorcery::Controller::Config.facebook.key}&display=page&redirect_uri=http%3A%2F%2Ftest.host%2Foauth%2Ftwitter%2Fcallback&response_type=code&scope=email%2Coffline_access&state=bla")
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
      allow(subject).to receive(:register_last_activity_time_to_db)

      sorcery_model_property_set(:authentications_class, Authentication)
      create_new_external_user(:facebook)
      get :test_login_from_facebook

      expect(flash[:notice]).to eq "Success!"
    end

    it "'login_from' fails if user doesn't exist" do
      sorcery_model_property_set(:authentications_class, Authentication)
      create_new_user
      get :test_login_from_facebook

      expect(flash[:alert]).to eq "Failed!"
    end

    it "on successful login_from the user is redirected to the url he originally wanted" do
      # dirty hack for rails 4
      allow(subject).to receive(:register_last_activity_time_to_db)

      sorcery_model_property_set(:authentications_class, Authentication)
      create_new_external_user(:facebook)
      get :test_return_to_with_external_facebook, {}, :return_to_url => "fuu"

      expect(response).to redirect_to("fuu")
      expect(flash[:notice]).to eq "Success!"
    end

    [:github, :google, :liveid, :vk].each do |provider|

      describe "with #{provider}" do

        it "login_at redirects correctly" do
          create_new_user
          get :"login_at_test_#{provider}"

          expect(response).to be_a_redirect
          expect(response).to redirect_to(provider_url provider)
        end

        it "'login_from' logins if user exists" do
          # dirty hack for rails 4
          allow(subject).to receive(:register_last_activity_time_to_db)

          sorcery_model_property_set(:authentications_class, Authentication)
          create_new_external_user(provider)
          get :"test_login_from_#{provider}"

          expect(flash[:notice]).to eq "Success!"
        end

        it "'login_from' fails if user doesn't exist" do
          sorcery_model_property_set(:authentications_class, Authentication)
          create_new_user
          get :"test_login_from_#{provider}"

          expect(flash[:alert]).to eq "Failed!"
        end

        it "on successful login_from the user is redirected to the url he originally wanted (#{provider})" do
          # dirty hack for rails 4
          allow(subject).to receive(:register_last_activity_time_to_db)

          sorcery_model_property_set(:authentications_class, Authentication)
          create_new_external_user(provider)
          get :"test_return_to_with_external_#{provider}", {}, :return_to_url => "fuu"

          expect(response).to redirect_to "fuu"
          expect(flash[:notice]).to eq "Success!"
        end
      end
    end

  end

  describe "OAuth with User Activation features" do
    before(:all) do
      if SORCERY_ORM == :active_record
        ActiveRecord::Migrator.migrate("#{Rails.root}/db/migrate/activation")
      end

      sorcery_reload!([:user_activation,:external], :user_activation_mailer => ::SorceryMailer)
      sorcery_controller_property_set(:external_providers, [:facebook, :github, :google, :liveid, :vk])

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
      sorcery_controller_external_property_set(:vk, :key, "eYVNBjBDi33aa9GkA3w")
      sorcery_controller_external_property_set(:vk, :secret, "XpbeSdCoaKSmQGSeokz5qcUATClRW5u08QWNfv71N8")
      sorcery_controller_external_property_set(:vk, :callback_url, "http://blabla.com")
    end

    after(:all) do
      if SORCERY_ORM == :active_record
        ActiveRecord::Migrator.rollback("#{Rails.root}/db/migrate/activation")
      end
    end

    after(:each) do
      User.sorcery_adapter.delete_all
    end

    it "does not send activation email to external users" do
      old_size = ActionMailer::Base.deliveries.size
      create_new_external_user(:facebook)

      expect(ActionMailer::Base.deliveries.size).to eq old_size
    end

    it "does not send external users an activation success email" do
      sorcery_model_property_set(:activation_success_email_method_name, nil)
      create_new_external_user(:facebook)
      old_size = ActionMailer::Base.deliveries.size
      @user.activate!

      expect(ActionMailer::Base.deliveries.size).to eq old_size
    end

    [:github, :google, :liveid, :vk].each do |provider|
      it "does not send activation email to external users (#{provider})" do
        old_size = ActionMailer::Base.deliveries.size
        create_new_external_user provider
        expect(ActionMailer::Base.deliveries.size).to eq old_size
      end

      it "does not send external users an activation success email (#{provider})" do
        sorcery_model_property_set(:activation_success_email_method_name, nil)
        create_new_external_user provider
        old_size = ActionMailer::Base.deliveries.size
        @user.activate!

        expect(ActionMailer::Base.deliveries.size).to eq old_size
      end
    end
  end

  describe "OAuth with user activation features"  do
    before(:all) do
      if SORCERY_ORM == :active_record
        ActiveRecord::Migrator.migrate("#{Rails.root}/db/migrate/external")
        ActiveRecord::Migrator.migrate("#{Rails.root}/db/migrate/activity_logging")
        User.reset_column_information
      end

      sorcery_reload!([:activity_logging, :external])
    end

    after(:all) do
      if SORCERY_ORM == :active_record
        ActiveRecord::Migrator.rollback("#{Rails.root}/db/migrate/external")
        ActiveRecord::Migrator.rollback("#{Rails.root}/db/migrate/activity_logging")
      end
    end

    %w(facebook github google liveid vk).each do |provider|
      context "when #{provider}" do
        before(:each) do
          User.sorcery_adapter.delete_all
          Authentication.sorcery_adapter.delete_all
          sorcery_controller_property_set(:register_login_time, true)
          stub_all_oauth2_requests!
          sorcery_model_property_set(:authentications_class, Authentication)
          create_new_external_user(provider.to_sym)
        end

        it "registers login time" do
          now = Time.now.in_time_zone
          get "test_login_from_#{provider}".to_sym

          expect(User.last.last_login_at).not_to be_nil
          expect(User.last.last_login_at.to_s(:db)).to be >= now.to_s(:db)
          expect(User.last.last_login_at.to_s(:db)).to be <= (now+2).to_s(:db)
        end

        it "does not register login time if configured so" do
          sorcery_controller_property_set(:register_login_time, false)
          now = Time.now.in_time_zone
          get "test_login_from_#{provider}".to_sym

          expect(User.last.last_login_at).to be_nil
        end
      end
    end
  end

  describe "OAuth with session timeout features" do
    before(:all) do
      if SORCERY_ORM == :active_record
        ActiveRecord::Migrator.migrate("#{Rails.root}/db/migrate/external")
        User.reset_column_information
      end

      sorcery_reload!([:session_timeout, :external])
    end

    after(:all) do
      ActiveRecord::Migrator.rollback("#{Rails.root}/db/migrate/external")
    end

    %w(facebook github google liveid vk).each do |provider|
      context "when #{provider}" do
        before(:each) do
          User.sorcery_adapter.delete_all
          Authentication.sorcery_adapter.delete_all
          sorcery_model_property_set(:authentications_class, Authentication)
          sorcery_controller_property_set(:session_timeout,0.5)
          stub_all_oauth2_requests!
          create_new_external_user(provider.to_sym)
        end

        after(:each) do
          Timecop.return
        end

        it "does not reset session before session timeout" do
          get "test_login_from_#{provider}".to_sym

          expect(session[:user_id]).not_to be_nil
          expect(flash[:notice]).to eq "Success!"
        end

        it "resets session after session timeout" do
          get "test_login_from_#{provider}".to_sym
          Timecop.travel(Time.now.in_time_zone+0.6)
          get :test_should_be_logged_in

          expect(session[:user_id]).to be_nil
          expect(response).to be_a_redirect
        end
      end
    end
  end

  def stub_all_oauth2_requests!
    access_token    = double(OAuth2::AccessToken)
    allow(access_token).to receive(:token_param=)
    response        = double(OAuth2::Response)
    allow(response).to receive(:body) { {
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
      "updated_time"=>"2011-02-16T20:59:38+0000",
      # response for VK auth
      "response"=>[
          {
            "uid"=>"123",
            "first_name"=>"Noam",
            "last_name"=>"Ben Ari"
            }
        ]}.to_json }
    allow(access_token).to receive(:get) { response }
    allow(access_token).to receive(:token) { "187041a618229fdaf16613e96e1caabc1e86e46bbfad228de41520e63fe45873684c365a14417289599f3" }
    # access_token params for VK auth
    allow(access_token).to receive(:params) { { "user_id"=>"100500", "email"=>"nbenari@gmail.com" } }
    allow_any_instance_of(OAuth2::Strategy::AuthCode).to receive(:get_token) { access_token }
  end

  def set_external_property
    sorcery_controller_property_set(:external_providers, [:facebook, :github, :google, :liveid, :vk])
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
    sorcery_controller_external_property_set(:vk, :key, "eYVNBjBDi33aa9GkA3w")
    sorcery_controller_external_property_set(:vk, :secret, "XpbeSdCoaKSmQGSeokz5qcUATClRW5u08QWNfv71N8")
    sorcery_controller_external_property_set(:vk, :callback_url, "http://blabla.com")
  end

  def provider_url(provider)
    {
      github: "https://github.com/login/oauth/authorize?client_id=#{::Sorcery::Controller::Config.github.key}&display=&redirect_uri=http%3A%2F%2Fblabla.com&response_type=code&scope=&state=",
      google: "https://accounts.google.com/o/oauth2/auth?client_id=#{::Sorcery::Controller::Config.google.key}&display=&redirect_uri=http%3A%2F%2Fblabla.com&response_type=code&scope=https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fuserinfo.email+https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fuserinfo.profile&state=",
      liveid: "https://oauth.live.com/authorize?client_id=#{::Sorcery::Controller::Config.liveid.key}&display=&redirect_uri=http%3A%2F%2Fblabla.com&response_type=code&scope=wl.basic+wl.emails+wl.offline_access&state=",
      vk: "https://oauth.vk.com/authorize?client_id=#{::Sorcery::Controller::Config.vk.key}&display=&redirect_uri=http%3A%2F%2Fblabla.com&response_type=code&scope=#{::Sorcery::Controller::Config.vk.scope}&state="
    }[provider]
  end

end

