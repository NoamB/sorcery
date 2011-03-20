require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

def stub_all_oauth2_requests!
  @client = OAuth2::Client.new("key","secret", :site => "http://myapi.com")
  OAuth2::Client.stub!(:new).and_return(@client)
  @acc_token = OAuth2::AccessToken.new(@client, "", "asd", nil, {})
  @webby = @client.web_server
  OAuth2::Strategy::WebServer.stub!(:new).and_return(@webby)
  @webby.stub!(:get_access_token).and_return(@acc_token)
  @acc_token.stub!(:get).and_return({"id"=>"123", "name"=>"Noam Ben Ari", "first_name"=>"Noam", "last_name"=>"Ben Ari", "link"=>"http://www.facebook.com/nbenari1", "hometown"=>{"id"=>"110619208966868", "name"=>"Haifa, Israel"}, "location"=>{"id"=>"106906559341067", "name"=>"Pardes Hanah, Hefa, Israel"}, "bio"=>"I'm a new daddy, and enjoying it!", "gender"=>"male", "email"=>"nbenari@gmail.com", "timezone"=>2, "locale"=>"en_US", "languages"=>[{"id"=>"108405449189952", "name"=>"Hebrew"}, {"id"=>"106059522759137", "name"=>"English"}, {"id"=>"112624162082677", "name"=>"Russian"}], "verified"=>true, "updated_time"=>"2011-02-16T20:59:38+0000"}.to_json)
end

describe 'MyApp' do
  before(:all) do
    ActiveRecord::Migrator.migrate("#{APP_ROOT}/db/migrate/oauth")
    sorcery_reload!([:oauth])
    sorcery_controller_property_set(:oauth_providers, [:facebook])
    sorcery_controller_oauth_property_set(:facebook, :key, "eYVNBjBDi33aa9GkA3w")
    sorcery_controller_oauth_property_set(:facebook, :secret, "XpbeSdCoaKSmQGSeokz5qcUATClRW5u08QWNfv71N8")
    sorcery_controller_oauth_property_set(:facebook, :callback_url, "http://blabla.com")
  end
  
  after(:all) do
    ActiveRecord::Migrator.rollback("#{APP_ROOT}/db/migrate/oauth")
  end
  # ----------------- OAuth -----------------------
  describe Sinatra::Application, "with OAuth features" do
  
    before(:each) do
      stub_all_oauth2_requests!
    end
      
    after(:each) do
      User.delete_all
      Authentication.delete_all
    end
    
    it "auth_at_provider redirects correctly" do
      create_new_user
      get "/auth_at_provider_test2"
      last_response.should be_a_redirect
      last_response.should redirect_to("http://myapi.com/oauth/authorize?client_id=key&redirect_uri=http%3A%2F%2Fblabla.com&scope=email%2Coffline_access&type=web_server")
    end
    
    it "'login_from_access_token' logins if user exists" do
      sorcery_model_property_set(:authentications_class, Authentication)
      create_new_external_user(:facebook)
      get "/test_login_from_access_token2"
      last_response.body.should == "Success!"
    end
    
    it "'login_from_access_token' fails if user doesn't exist" do
      sorcery_model_property_set(:authentications_class, Authentication)
      create_new_user
      get "/test_login_from_access_token2"
      last_response.body.should == "Failed!"
    end
  end
  
  describe Sinatra::Application, "'create_from_provider!'" do
    before(:each) do
      stub_all_oauth2_requests!
      User.delete_all
      Authentication.delete_all
    end
      
    it "should create a new user" do
      sorcery_model_property_set(:authentications_class, Authentication)
      sorcery_controller_oauth_property_set(:facebook, :user_info_mapping, {:username => "name"})
      lambda do
        get "/test_create_from_provider", :provider => "facebook"
      end.should change(User, :count).by(1)
      User.first.username.should == "Noam Ben Ari"
    end
    
    it "should support nested attributes" do
      sorcery_model_property_set(:authentications_class, Authentication)
      sorcery_controller_oauth_property_set(:facebook, :user_info_mapping, {:username => "hometown/name"})
      lambda do
        get "/test_create_from_provider", :provider => "facebook"
      end.should change(User, :count).by(1)
      User.first.username.should == "Haifa, Israel"
    end
  end
  
  describe Sinatra::Application, "OAuth with User Activation features" do
    before(:all) do
      ActiveRecord::Migrator.migrate("#{APP_ROOT}/db/migrate/activation")
      sorcery_reload!([:user_activation,:oauth], :user_activation_mailer => ::SorceryMailer)
      sorcery_controller_property_set(:oauth_providers, [:facebook])
      sorcery_controller_oauth_property_set(:facebook, :key, "eYVNBjBDi33aa9GkA3w")
      sorcery_controller_oauth_property_set(:facebook, :secret, "XpbeSdCoaKSmQGSeokz5qcUATClRW5u08QWNfv71N8")
      sorcery_controller_oauth_property_set(:facebook, :callback_url, "http://blabla.com")
    end
    
    after(:all) do
      ActiveRecord::Migrator.rollback("#{APP_ROOT}/db/migrate/activation")
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
  end
  
end