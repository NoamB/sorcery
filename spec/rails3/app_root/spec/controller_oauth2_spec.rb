require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe ApplicationController do
  before(:all) do
    ActiveRecord::Migrator.migrate("#{Rails.root}/db/migrate/oauth")
    sorcery_reload!([:oauth])
    sorcery_controller_property_set(:oauth_providers, [:facebook])
    sorcery_controller_oauth_property_set(:facebook, :key, "eYVNBjBDi33aa9GkA3w")
    sorcery_controller_oauth_property_set(:facebook, :secret, "XpbeSdCoaKSmQGSeokz5qcUATClRW5u08QWNfv71N8")
    sorcery_controller_oauth_property_set(:facebook, :callback_url, "http://blabla.com")
  end
  
  after(:all) do
    ActiveRecord::Migrator.rollback("#{Rails.root}/db/migrate/oauth")
  end
  # ----------------- OAuth -----------------------
  describe ApplicationController, "with OAuth features" do
  
    before(:each) do
      @client = OAuth2::Client.new("key","secret", :site => "http://myapi.com")
      OAuth2::Client.stub!(:new).and_return(@client)
      @acc_token = OAuth2::AccessToken.new(@client, "", "asd", nil, {})
      @webby = @client.web_server
      OAuth2::Strategy::WebServer.stub!(:new).and_return(@webby)
      @webby.stub!(:get_access_token).and_return(@acc_token)
    end
      
    after(:each) do
      User.delete_all
    end
    
    it "auth_at_provider redirects correctly" do
      create_new_user
      get :auth_at_provider_test2
      response.should be_a_redirect
      response.should redirect_to("http://myapi.com/oauth/authorize?client_id=key&redirect_uri=http%3A%2F%2Fblabla.com&scope=email%2Coffline_access&type=web_server")
    end
    
    it "'login_from_access_token' logins if user exists" do
      sorcery_model_property_set(:user_providers_class, UserProvider)
      create_new_external_user
      get :test_login_from_access_token2
      flash[:notice].should == "Success!"
    end
    
    it "'login_from_access_token' fails if user doesn't exist" do
      sorcery_model_property_set(:user_providers_class, UserProvider)
      create_new_user
      get :test_login_from_access_token2
      flash[:alert].should == "Failed!"
    end
  end
  
  describe ApplicationController, "OAuth with User Activation features" do
    before(:all) do
      ActiveRecord::Migrator.migrate("#{Rails.root}/db/migrate/activation")
      sorcery_reload!([:user_activation,:oauth], :user_activation_mailer => ::SorceryMailer)
      sorcery_controller_property_set(:oauth_providers, [:facebook])
      sorcery_controller_oauth_property_set(:facebook, :key, "eYVNBjBDi33aa9GkA3w")
      sorcery_controller_oauth_property_set(:facebook, :secret, "XpbeSdCoaKSmQGSeokz5qcUATClRW5u08QWNfv71N8")
      sorcery_controller_oauth_property_set(:facebook, :callback_url, "http://blabla.com")
    end
    
    after(:all) do
      ActiveRecord::Migrator.rollback("#{Rails.root}/db/migrate/activation")
    end
    
    after(:each) do
      User.delete_all
    end
    
    it "should not send activation email to external users" do
      old_size = ActionMailer::Base.deliveries.size
      create_new_external_user
      ActionMailer::Base.deliveries.size.should == old_size
    end
    
    it "should not send external users an activation success email" do
      sorcery_model_property_set(:activation_success_email_method_name, nil)
      create_new_external_user
      old_size = ActionMailer::Base.deliveries.size
      @user.activate!
      ActionMailer::Base.deliveries.size.should == old_size
    end
  end
end