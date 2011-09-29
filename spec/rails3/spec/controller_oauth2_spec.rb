require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/../../shared_examples/controller_oauth2_shared_examples')

def stub_all_oauth2_requests!
  @client = OAuth2::Client.new("key","secret", :site => "http://myapi.com")
  OAuth2::Client.stub!(:new).and_return(@client)
  @acc_token = OAuth2::AccessToken.new(@client, "asd", {})
  @client.stub!(:get_token).and_return(@acc_token)
  @acc_token.stub!(:get).and_return({"id"=>"123", "name"=>"Noam Ben Ari", "first_name"=>"Noam", "last_name"=>"Ben Ari", "link"=>"http://www.facebook.com/nbenari1", "hometown"=>{"id"=>"110619208966868", "name"=>"Haifa, Israel"}, "location"=>{"id"=>"106906559341067", "name"=>"Pardes Hanah, Hefa, Israel"}, "bio"=>"I'm a new daddy, and enjoying it!", "gender"=>"male", "email"=>"nbenari@gmail.com", "timezone"=>2, "locale"=>"en_US", "languages"=>[{"id"=>"108405449189952", "name"=>"Hebrew"}, {"id"=>"106059522759137", "name"=>"English"}, {"id"=>"112624162082677", "name"=>"Russian"}], "verified"=>true, "updated_time"=>"2011-02-16T20:59:38+0000"}.to_json)
end

describe ApplicationController do
  before(:all) do
    ActiveRecord::Migrator.migrate("#{Rails.root}/db/migrate/external")
    sorcery_reload!([:external])
    sorcery_controller_property_set(:external_providers, [:facebook, :github])
    sorcery_controller_external_property_set(:facebook, :key, "eYVNBjBDi33aa9GkA3w")
    sorcery_controller_external_property_set(:facebook, :secret, "XpbeSdCoaKSmQGSeokz5qcUATClRW5u08QWNfv71N8")
    sorcery_controller_external_property_set(:facebook, :callback_url, "http://blabla.com")
    sorcery_controller_external_property_set(:github, :key, "eYVNBjBDi33aa9GkA3w")
    sorcery_controller_external_property_set(:github, :secret, "XpbeSdCoaKSmQGSeokz5qcUATClRW5u08QWNfv71N8")
    sorcery_controller_external_property_set(:github, :callback_url, "http://blabla.com")
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
      response.should redirect_to("http://myapi.com/oauth/authorize?redirect_uri=http%3A%2F%2Fblabla.com&scope=email%2Coffline_access")
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
      response.should redirect_to("http://myapi.com/oauth/authorize?redirect_uri=http%3A%2F%2Fblabla.com&scope=")
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

  end


  describe ApplicationController do
    it_behaves_like "oauth2_controller"
  end

  describe ApplicationController, "OAuth with User Activation features" do
    before(:all) do
      ActiveRecord::Migrator.migrate("#{Rails.root}/db/migrate/activation")
      sorcery_reload!([:user_activation,:external], :user_activation_mailer => ::SorceryMailer)
      sorcery_controller_property_set(:external_providers, [:facebook, :github])
      sorcery_controller_external_property_set(:facebook, :key, "eYVNBjBDi33aa9GkA3w")
      sorcery_controller_external_property_set(:facebook, :secret, "XpbeSdCoaKSmQGSeokz5qcUATClRW5u08QWNfv71N8")
      sorcery_controller_external_property_set(:facebook, :callback_url, "http://blabla.com")
      sorcery_controller_external_property_set(:github, :key, "eYVNBjBDi33aa9GkA3w")
      sorcery_controller_external_property_set(:github, :secret, "XpbeSdCoaKSmQGSeokz5qcUATClRW5u08QWNfv71N8")
      sorcery_controller_external_property_set(:github, :callback_url, "http://blabla.com")
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
  end
end