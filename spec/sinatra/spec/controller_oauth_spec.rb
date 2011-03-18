require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'ostruct'

def stub_all_oauth_requests!
  @consumer = OAuth::Consumer.new("key","secret", :site => "http://myapi.com")
  OAuth::Consumer.stub!(:new).and_return(@consumer)
  
  @req_token = OAuth::RequestToken.new(@consumer)
  @consumer.stub!(:get_request_token).and_return(@req_token)
  @acc_token = OAuth::AccessToken.new(@consumer)
  @req_token.stub!(:get_access_token).and_return(@acc_token)
  session[:request_token] = @req_token
  response = OpenStruct.new()
  response.body = {"following"=>false, "listed_count"=>0, "profile_link_color"=>"0084B4", "profile_image_url"=>"http://a1.twimg.com/profile_images/536178575/noamb_normal.jpg", "description"=>"Programmer/Heavy Metal Fan/New Father", "status"=>{"text"=>"coming soon to sorcery gem: twitter and facebook authentication support.", "truncated"=>false, "favorited"=>false, "source"=>"web", "geo"=>nil, "in_reply_to_screen_name"=>nil, "in_reply_to_user_id"=>nil, "in_reply_to_status_id_str"=>nil, "created_at"=>"Sun Mar 06 23:01:12 +0000 2011", "contributors"=>nil, "place"=>nil, "retweeted"=>false, "in_reply_to_status_id"=>nil, "in_reply_to_user_id_str"=>nil, "coordinates"=>nil, "retweet_count"=>0, "id"=>44533012284706816, "id_str"=>"44533012284706816"}, "show_all_inline_media"=>false, "geo_enabled"=>true, "profile_sidebar_border_color"=>"a8c7f7", "url"=>nil, "followers_count"=>10, "screen_name"=>"nbenari", "profile_use_background_image"=>true, "location"=>"Israel", "statuses_count"=>25, "profile_background_color"=>"022330", "lang"=>"en", "verified"=>false, "notifications"=>false, "profile_background_image_url"=>"http://a3.twimg.com/profile_background_images/104087198/04042010339.jpg", "favourites_count"=>5, "created_at"=>"Fri Nov 20 21:58:19 +0000 2009", "is_translator"=>false, "contributors_enabled"=>false, "protected"=>false, "follow_request_sent"=>false, "time_zone"=>"Greenland", "profile_text_color"=>"333333", "name"=>"Noam Ben Ari", "friends_count"=>10, "profile_sidebar_fill_color"=>"C0DFEC", "id"=>123, "id_str"=>"91434812", "profile_background_tile"=>false, "utc_offset"=>-10800}.to_json
  @acc_token.stub!(:get).and_return(response)
end

describe 'MyApp' do
  before(:all) do
    ActiveRecord::Migrator.migrate("#{APP_ROOT}/db/migrate/oauth")
    sorcery_reload!([:oauth])
    sorcery_controller_property_set(:oauth_providers, [:twitter])
    sorcery_controller_oauth_property_set(:twitter, :key, "eYVNBjBDi33aa9GkA3w")
    sorcery_controller_oauth_property_set(:twitter, :secret, "XpbeSdCoaKSmQGSeokz5qcUATClRW5u08QWNfv71N8")
    sorcery_controller_oauth_property_set(:twitter, :callback_url, "http://blabla.com")
  end
  
  after(:all) do
    ActiveRecord::Migrator.rollback("#{APP_ROOT}/db/migrate/oauth")
  end
  # ----------------- OAuth -----------------------
  describe 'MyApp', "'login_from_access_token'" do
  
    before(:each) do
      stub_all_oauth_requests!
    end
      
    after(:each) do
      User.delete_all
    end
    
    it "auth_at_provider redirects correctly" do
      create_new_user
      get :auth_at_provider_test
      response.should be_a_redirect
      response.should redirect_to("http://myapi.com/oauth/authorize?oauth_callback=http%3A%2F%2Fblabla.com&oauth_token=")
    end
    
    it "logins if user exists" do
      sorcery_model_property_set(:authentications_class, Authentication)
      create_new_external_user(:twitter)
      get :test_login_from_access_token, :oauth_verifier => "blablaRERASDFcxvSDFA"
      flash[:notice].should == "Success!"
    end
    
    it "'login_from_access_token' fails if user doesn't exist" do
      sorcery_model_property_set(:authentications_class, Authentication)
      create_new_user
      get :test_login_from_access_token, :oauth_verifier => "blablaRERASDFcxvSDFA"
      flash[:alert].should == "Failed!"
    end
  end
  
  describe 'MyApp', "'create_from_provider!'" do
    before(:each) do
      stub_all_oauth_requests!
      User.delete_all
    end
      
    it "should create a new user" do
      sorcery_model_property_set(:authentications_class, Authentication)
      sorcery_controller_oauth_property_set(:twitter, :user_info_mapping, {:username => "screen_name"})
      lambda do
        get :test_create_from_provider, :provider => "twitter"
      end.should change(User, :count).by(1)
      User.first.username.should == "nbenari"
    end
    
    it "should support nested attributes" do
      sorcery_model_property_set(:authentications_class, Authentication)
      sorcery_controller_oauth_property_set(:twitter, :user_info_mapping, {:username => "status/text"})
      lambda do
        get :test_create_from_provider, :provider => "twitter"
      end.should change(User, :count).by(1)
      User.first.username.should == "coming soon to sorcery gem: twitter and facebook authentication support."
    end
  end
  
  describe 'MyApp', "OAuth with User Activation features" do
    before(:all) do
      ActiveRecord::Migrator.migrate("#{APP_ROOT}/db/migrate/activation")
      sorcery_reload!([:user_activation,:oauth], :user_activation_mailer => ::SorceryMailer)
    end
    
    after(:all) do
      ActiveRecord::Migrator.rollback("#{APP_ROOT}/db/migrate/activation")
    end
    
    after(:each) do
      User.delete_all
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
end