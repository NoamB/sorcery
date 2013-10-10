require 'spec_helper'

require 'shared_examples/controller_oauth_shared_examples'
require 'ostruct'

def stub_all_oauth_requests!
  @consumer = OAuth::Consumer.new("key","secret", :site => "http://myapi.com")
  OAuth::Consumer.stub(:new).and_return(@consumer)

  @req_token = OAuth::RequestToken.new(@consumer)
  @consumer.stub(:get_request_token).and_return(@req_token)
  @acc_token = OAuth::AccessToken.new(@consumer)
  @req_token.stub(:get_access_token).and_return(@acc_token)
  session[:request_token] = @req_token.token
  session[:request_token_secret] = @req_token.secret
  OAuth::RequestToken.stub(:new).and_return(@req_token)
  response = OpenStruct.new()
  response.body = {"following"=>false, "listed_count"=>0, "profile_link_color"=>"0084B4", "profile_image_url"=>"http://a1.twimg.com/profile_images/536178575/noamb_normal.jpg", "description"=>"Programmer/Heavy Metal Fan/New Father", "status"=>{"text"=>"coming soon to sorcery gem: twitter and facebook authentication support.", "truncated"=>false, "favorited"=>false, "source"=>"web", "geo"=>nil, "in_reply_to_screen_name"=>nil, "in_reply_to_user_id"=>nil, "in_reply_to_status_id_str"=>nil, "created_at"=>"Sun Mar 06 23:01:12 +0000 2011", "contributors"=>nil, "place"=>nil, "retweeted"=>false, "in_reply_to_status_id"=>nil, "in_reply_to_user_id_str"=>nil, "coordinates"=>nil, "retweet_count"=>0, "id"=>44533012284706816, "id_str"=>"44533012284706816"}, "show_all_inline_media"=>false, "geo_enabled"=>true, "profile_sidebar_border_color"=>"a8c7f7", "url"=>nil, "followers_count"=>10, "screen_name"=>"nbenari", "profile_use_background_image"=>true, "location"=>"Israel", "statuses_count"=>25, "profile_background_color"=>"022330", "lang"=>"en", "verified"=>false, "notifications"=>false, "profile_background_image_url"=>"http://a3.twimg.com/profile_background_images/104087198/04042010339.jpg", "favourites_count"=>5, "created_at"=>"Fri Nov 20 21:58:19 +0000 2009", "is_translator"=>false, "contributors_enabled"=>false, "protected"=>false, "follow_request_sent"=>false, "time_zone"=>"Greenland", "profile_text_color"=>"333333", "name"=>"Noam Ben Ari", "friends_count"=>10, "profile_sidebar_fill_color"=>"C0DFEC", "id"=>123, "id_str"=>"91434812", "profile_background_tile"=>false, "utc_offset"=>-10800}.to_json
  @acc_token.stub(:get).and_return(response)
end

describe SorceryController do
  before(:all) do
    ActiveRecord::Migrator.migrate("#{Rails.root}/db/migrate/external")
    User.reset_column_information

    sorcery_reload!([:external])
    sorcery_controller_property_set(:external_providers, [:twitter])
    sorcery_controller_external_property_set(:twitter, :key, "eYVNBjBDi33aa9GkA3w")
    sorcery_controller_external_property_set(:twitter, :secret, "XpbeSdCoaKSmQGSeokz5qcUATClRW5u08QWNfv71N8")
    sorcery_controller_external_property_set(:twitter, :callback_url, "http://blabla.com")
  end

  after(:all) do
    ActiveRecord::Migrator.rollback("#{Rails.root}/db/migrate/external")
  end
  # ----------------- OAuth -----------------------
  describe SorceryController, "'using external API to login'" do

    before(:each) do
      stub_all_oauth_requests!
    end

    after(:each) do
      User.delete_all
      Authentication.delete_all
    end

    context "when callback_url begin with /" do
      before do
        sorcery_controller_external_property_set(:twitter, :callback_url, "/oauth/twitter/callback")
      end
      it "login_at redirects correctly" do
        create_new_user
        get :login_at_test
        response.should be_a_redirect
        response.should redirect_to("http://myapi.com/oauth/authorize?oauth_callback=http%3A%2F%2Ftest.host%2Foauth%2Ftwitter%2Fcallback&oauth_token=")
      end
      after do
        sorcery_controller_external_property_set(:twitter, :callback_url, "http://blabla.com")
      end
    end

    context "when callback_url begin with http://" do
      it "login_at redirects correctly", pending: true do
        create_new_user
        get :login_at_test
        response.should be_a_redirect
        response.should redirect_to("http://myapi.com/oauth/authorize?oauth_callback=http%3A%2F%2Fblabla.com&oauth_token=")
      end
    end

    it "logins if user exists" do
      sorcery_model_property_set(:authentications_class, Authentication)
      create_new_external_user(:twitter)
      get :test_login_from, :oauth_verifier => "blablaRERASDFcxvSDFA"
      flash[:notice].should == "Success!"
    end

    it "'login_from' fails if user doesn't exist" do
      sorcery_model_property_set(:authentications_class, Authentication)
      create_new_user
      get :test_login_from, :oauth_verifier => "blablaRERASDFcxvSDFA"
      flash[:alert].should == "Failed!"
    end

    it "on successful 'login_from' the user should be redirected to the url he originally wanted" do
      sorcery_model_property_set(:authentications_class, Authentication)
      create_new_external_user(:twitter)
      get :test_return_to_with_external, {}, :return_to_url => "fuu"
      response.should redirect_to("fuu")
      flash[:notice].should == "Success!"
    end

  end

  describe SorceryController do
    it_behaves_like "oauth_controller"
  end

  describe SorceryController, "using OAuth with User Activation features" do
    before(:all) do
      ActiveRecord::Migrator.migrate("#{Rails.root}/db/migrate/activation")
      sorcery_reload!([:user_activation,:external], :user_activation_mailer => ::SorceryMailer)
    end

    after(:all) do
      ActiveRecord::Migrator.rollback("#{Rails.root}/db/migrate/activation")
    end

    after(:each) do
      User.delete_all
      Authentication.delete_all
    end

    it "should not send activation email to external users" do
      old_size = ActionMailer::Base.deliveries.size
      create_new_external_user(:twitter)
      ActionMailer::Base.deliveries.size.should == old_size
    end

    it "should not send external users an activation success email" do
      sorcery_model_property_set(:activation_success_email_method_name, nil)
      create_new_external_user(:twitter)
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
      User.reset_column_information
    end

    context "when twitter" do
      before(:each) do
        User.delete_all
        Authentication.delete_all
        sorcery_controller_property_set(:register_login_time, true)
        stub_all_oauth_requests!
        sorcery_model_property_set(:authentications_class, Authentication)
        create_new_external_user(:twitter)
      end

      it "should register login time" do
        now = Time.now.in_time_zone
        get :test_login_from
        User.last.last_login_at.should_not be_nil
        User.last.last_login_at.to_s(:db).should >= now.to_s(:db)
        User.last.last_login_at.to_s(:db).should <= (now+2).to_s(:db)
      end

      it "should not register login time if configured so" do
        sorcery_controller_property_set(:register_login_time, false)
        now = Time.now.in_time_zone
        get :test_login_from
        User.last.last_login_at.should be_nil
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

    context "when twitter" do
      before(:each) do
        User.delete_all
        Authentication.delete_all
        sorcery_model_property_set(:authentications_class, Authentication)
        sorcery_controller_property_set(:session_timeout,0.5)
        stub_all_oauth_requests!
        create_new_external_user(:twitter)
      end

      after(:each) do
        Timecop.return
      end

      it "should not reset session before session timeout" do
        get :test_login_from
        session[:user_id].should_not be_nil
        flash[:notice].should == "Success!"
      end

      it "should reset session after session timeout" do
        get :test_login_from
        Timecop.travel(Time.now.in_time_zone+0.6)
        get :test_should_be_logged_in
        session[:user_id].should be_nil
        response.should be_a_redirect
      end
    end
  end
end
