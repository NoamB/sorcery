require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe ApplicationController do
  
  # ----------------- OAuth -----------------------
  describe ApplicationController, "with OAuth features" do
    before(:all) do
      ActiveRecord::Migrator.migrate("#{Rails.root}/db/migrate/oauth")
      sorcery_reload!([:oauth])
      sorcery_controller_property_set(:oauth_providers, [:twitter])
      sorcery_controller_oauth_property_set(:twitter, :key, "eYVNBjBDi33aa9GkA3w")
      sorcery_controller_oauth_property_set(:twitter, :secret, "XpbeSdCoaKSmQGSeokz5qcUATClRW5u08QWNfv71N8")
      sorcery_controller_oauth_property_set(:twitter, :callback_url, "http://blabla.com")
    end
    
    before(:each) do
      create_new_user
    end
    
    after(:all) do
      ActiveRecord::Migrator.rollback("#{Rails.root}/db/migrate/oauth")
    end
    
    after(:each) do
      User.delete_all
    end
    
    it "auth_at_provider redirects correctly" do
      get :auth_at_provider_test
      response.should be_a_redirect
      response.should redirect_to("https://api.twitter.com/oauth/authorize?oauth_callback=http%3A%2F%2Fblabla.com&oauth_token=#{session[:request_token].token}")
    end
  end
end