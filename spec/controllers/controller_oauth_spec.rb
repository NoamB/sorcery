require 'spec_helper'

# require 'shared_examples/controller_oauth_shared_examples'
require 'ostruct'

def stub_all_oauth_requests!
  consumer = OAuth::Consumer.new("key","secret", :site => "http://myapi.com")
  req_token = OAuth::RequestToken.new(consumer)
  acc_token = OAuth::AccessToken.new(consumer)

  response = OpenStruct.new()
  response.body = {"following"=>false, "listed_count"=>0, "profile_link_color"=>"0084B4", "profile_image_url"=>"http://a1.twimg.com/profile_images/536178575/noamb_normal.jpg", "description"=>"Programmer/Heavy Metal Fan/New Father", "status"=>{"text"=>"coming soon to sorcery gem: twitter and facebook authentication support.", "truncated"=>false, "favorited"=>false, "source"=>"web", "geo"=>nil, "in_reply_to_screen_name"=>nil, "in_reply_to_user_id"=>nil, "in_reply_to_status_id_str"=>nil, "created_at"=>"Sun Mar 06 23:01:12 +0000 2011", "contributors"=>nil, "place"=>nil, "retweeted"=>false, "in_reply_to_status_id"=>nil, "in_reply_to_user_id_str"=>nil, "coordinates"=>nil, "retweet_count"=>0, "id"=>44533012284706816, "id_str"=>"44533012284706816"}, "show_all_inline_media"=>false, "geo_enabled"=>true, "profile_sidebar_border_color"=>"a8c7f7", "url"=>nil, "followers_count"=>10, "screen_name"=>"nbenari", "profile_use_background_image"=>true, "location"=>"Israel", "statuses_count"=>25, "profile_background_color"=>"022330", "lang"=>"en", "verified"=>false, "notifications"=>false, "profile_background_image_url"=>"http://a3.twimg.com/profile_background_images/104087198/04042010339.jpg", "favourites_count"=>5, "created_at"=>"Fri Nov 20 21:58:19 +0000 2009", "is_translator"=>false, "contributors_enabled"=>false, "protected"=>false, "follow_request_sent"=>false, "time_zone"=>"Greenland", "profile_text_color"=>"333333", "name"=>"Noam Ben Ari", "friends_count"=>10, "profile_sidebar_fill_color"=>"C0DFEC", "id"=>123, "id_str"=>"91434812", "profile_background_tile"=>false, "utc_offset"=>-10800}.to_json

  session[:request_token] = req_token.token
  session[:request_token_secret] = req_token.secret

  allow(OAuth::Consumer).to receive(:new) { consumer }
  allow(consumer).to receive(:get_request_token) { req_token }
  allow(req_token).to receive(:get_access_token) { acc_token }
  allow(OAuth::RequestToken).to receive(:new) { req_token }
  allow(acc_token).to receive(:get) { response }
end

describe SorceryController do

  let(:user) { double('user', id: 42) }

  before(:all) do
    sorcery_reload!([:external])
    sorcery_controller_property_set(:external_providers, [:twitter, :jira])
    sorcery_controller_external_property_set(:twitter, :key, "eYVNBjBDi33aa9GkA3w")
    sorcery_controller_external_property_set(:twitter, :secret, "XpbeSdCoaKSmQGSeokz5qcUATClRW5u08QWNfv71N8")
    sorcery_controller_external_property_set(:twitter, :callback_url, "http://blabla.com")

    sorcery_controller_external_property_set(:jira, :key, "7810b8e317ebdc81601c72f8daecc0f1")
    sorcery_controller_external_property_set(:jira, :secret, "MyAppUsingJira")
    sorcery_controller_external_property_set(:jira, :site, "http://jira.mycompany.com/plugins/servlet/oauth")
    sorcery_controller_external_property_set(:jira, :signature_method, "RSA-SHA1")
    sorcery_controller_external_property_set(:jira, :private_key_file, "myrsakey.pem")
    sorcery_controller_external_property_set(:jira, :callback_url, "http://myappusingjira.com/home")
  end

  # ----------------- OAuth -----------------------
  describe SorceryController, "'using external API to login'" do

    before(:each) do
      stub_all_oauth_requests!
    end

    context "when callback_url begin with /" do
      before do
        sorcery_controller_external_property_set(:twitter, :callback_url, "/oauth/twitter/callback")
      end
      it "login_at redirects correctly" do
        get :login_at_test
        expect(response).to be_a_redirect
        expect(response).to redirect_to("http://myapi.com/oauth/authorize?oauth_callback=http%3A%2F%2Ftest.host%2Foauth%2Ftwitter%2Fcallback&oauth_token=")
      end
      after do
        sorcery_controller_external_property_set(:twitter, :callback_url, "http://blabla.com")
      end
    end

    context "when callback_url begin with http://" do
      it "login_at redirects correctly", pending: true do
        get :login_at_test
        expect(response).to be_a_redirect
        expect(response).to redirect_to("http://myapi.com/oauth/authorize?oauth_callback=http%3A%2F%2Fblabla.com&oauth_token=")
      end
    end

    it "logins if user exists" do
      expect(User).to receive(:load_from_provider).with(:twitter, '123').and_return(user)

      get :test_login_from, :oauth_verifier => "blablaRERASDFcxvSDFA"
      expect(flash[:notice]).to eq "Success!"
    end

    it "'login_from' fails if user doesn't exist" do
      expect(User).to receive(:load_from_provider).with(:twitter, '123').and_return(nil)

      get :test_login_from, :oauth_verifier => "blablaRERASDFcxvSDFA"
      expect(flash[:alert]).to eq "Failed!"
    end

    it "on successful 'login_from' the user is redirected to the url he originally wanted" do
      expect(User).to receive(:load_from_provider).with(:twitter, '123').and_return(user)
      get :test_return_to_with_external, {}, :return_to_url => "fuu"
      expect(response).to redirect_to("fuu")
      expect(flash[:notice]).to eq "Success!"
    end

    context "when jira" do
      it "user logins successfully" do
        get :login_at_test_jira
        expect(session[:request_token]).not_to be_nil
        expect(response).to be_a_redirect
      end
    end

  end

  describe SorceryController do
    describe "using 'create_from'" do
      before(:each) do
        stub_all_oauth_requests!
      end

      it "creates a new user" do
        sorcery_controller_external_property_set(:twitter, :user_info_mapping, {:username => "screen_name"})
        expect(User).to receive(:load_from_provider).with('twitter', '123').and_return(nil)
        expect(User).to receive(:create_from_provider).with('twitter', '123', {username: 'nbenari'}).and_return(user)

        get :test_create_from_provider, :provider => "twitter"
      end

      it "supports nested attributes" do
        sorcery_controller_external_property_set(:twitter, :user_info_mapping, {:username => "status/text"})
        expect(User).to receive(:load_from_provider).with('twitter', '123').and_return(nil)
        expect(User).to receive(:create_from_provider).with('twitter', '123', {username: 'coming soon to sorcery gem: twitter and facebook authentication support.'}).and_return(user)

        get :test_create_from_provider, :provider => "twitter"
      end

      it "does not crash on missing nested attributes" do
        sorcery_controller_external_property_set(:twitter, :user_info_mapping, {:username => "status/text", :created_at => "does/not/exist"})
        expect(User).to receive(:load_from_provider).with('twitter', '123').and_return(nil)
        expect(User).to receive(:create_from_provider).with('twitter', '123', {username: 'coming soon to sorcery gem: twitter and facebook authentication support.'}).and_return(user)

        get :test_create_from_provider, :provider => "twitter"
      end

      it "binds new provider" do
        sorcery_model_property_set(:authentications_class, UserProvider)

        allow(user).to receive_message_chain(:sorcery_config, :username_attribute_names, :first) { :username }
        allow(user).to receive(:username).and_return('bla@bla.com')
        login_user(user)

        expect(user).to receive(:add_provider_to_user).with('twitter', '123')
        get :test_add_second_provider, :provider => "twitter"
      end

      describe "with a block" do
        it "does not create user" do
          sorcery_model_property_set(:authentications_class, Authentication)
          sorcery_controller_external_property_set(:twitter, :user_info_mapping, {:username => "screen_name"})

          u = double('user')
          expect(User).to receive(:load_from_provider).with('twitter', '123').and_return(nil)
          expect(User).to receive(:create_from_provider).with('twitter', '123', {username: 'nbenari'}).and_return(u).and_yield(u)

          get :test_create_from_provider_with_block, :provider => "twitter"
        end

      end
    end
  end

  describe SorceryController, "OAuth with user activation features"  do
    before(:all) do
      sorcery_reload!([:activity_logging, :external])
    end

    context "when twitter" do
      before(:each) do
        sorcery_controller_property_set(:register_login_time, true)
        sorcery_controller_property_set(:register_logout_time, false)
        sorcery_controller_property_set(:register_last_activity_time, false)
        sorcery_controller_property_set(:register_last_ip_address, false)
        stub_all_oauth_requests!
      end

      it "registers login time" do
        now = Time.now.in_time_zone
        Timecop.freeze(now)
        expect(User).to receive(:load_from_provider).and_return(user)
        expect(user).to receive(:set_last_login_at).with(be_within(0.1).of(now))
        get :test_login_from
        Timecop.return
      end

      it "does not register login time if configured so" do
        sorcery_controller_property_set(:register_login_time, false)
        now = Time.now.in_time_zone
        Timecop.freeze(now)
        expect(User).to receive(:load_from_provider).and_return(user)
        expect(user).to receive(:set_last_login_at).never
        get :test_login_from
        Timecop.return
      end
    end
  end

  describe SorceryController, "OAuth with session timeout features" do
    before(:all) do
      if SORCERY_ORM == :active_record
        ActiveRecord::Migrator.migrate("#{Rails.root}/db/migrate/external")
        User.reset_column_information
      end

      sorcery_reload!([:session_timeout, :external])
    end

    after(:all) do
      if SORCERY_ORM == :active_record
        ActiveRecord::Migrator.rollback("#{Rails.root}/db/migrate/external")
      end
    end

    context "when twitter" do
      before(:each) do
        sorcery_model_property_set(:authentications_class, Authentication)
        sorcery_controller_property_set(:session_timeout,0.5)
        stub_all_oauth_requests!
      end

      after(:each) do
        Timecop.return
      end

      it "does not reset session before session timeout" do
        expect(User).to receive(:load_from_provider).with(:twitter, '123').and_return(user)
        get :test_login_from

        expect(session[:user_id]).not_to be_nil
        expect(flash[:notice]).to eq "Success!"
      end

      it "resets session after session timeout" do
        get :test_login_from
        Timecop.travel(Time.now.in_time_zone+0.6)
        get :test_should_be_logged_in

        expect(session[:user_id]).to be_nil
        expect(response).to be_a_redirect
      end
    end
  end
end
