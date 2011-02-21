require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "User with remember_me submodule" do
  before(:all) do
    ActiveRecord::Migrator.migrate("#{Rails.root}/db/migrate/remember_me")
  end
  
  after(:all) do
    ActiveRecord::Migrator.rollback("#{Rails.root}/db/migrate/remember_me")
  end

  # ----------------- PLUGIN CONFIGURATION -----------------------
  describe User, "loaded plugin configuration" do
    before(:all) do
      plugin_model_configure([:remember_me])
    end
  
    after(:each) do
      User.sorcery_config.reset!
    end
    
    it "should allow configuration option 'remember_me_token_attribute_name'" do
      plugin_set_model_config_property(:remember_me_token_attribute_name, :my_token)
      User.sorcery_config.remember_me_token_attribute_name.should equal(:my_token)
    end

    it "should allow configuration option 'remember_me_token_expires_at_attribute_name'" do
      plugin_set_model_config_property(:remember_me_token_expires_at_attribute_name, :my_expires)
      User.sorcery_config.remember_me_token_expires_at_attribute_name.should equal(:my_expires)
    end
    
    it "should respond to 'remember_me!'" do
      create_new_user
      @user.should respond_to(:remember_me!)
    end
    
    it "should respond to 'forget_me!'" do
      create_new_user
      @user.should respond_to(:forget_me!)
    end
    
    it "should generate a new token on 'remember_me!'" do
      create_new_user
      @user.remember_me_token.should be_nil
      @user.remember_me!
      @user.remember_me_token.should_not be_nil
    end
    
    it "should set an expiration based on 'remember_me_for' attribute" do
      create_new_user
      plugin_set_model_config_property(:remember_me_for, 2 * 60 * 60 * 24)
      @user.remember_me!
      @user.remember_me_token_expires_at.to_s.should == (Time.now + 2 * 60 * 60 * 24).utc.to_s
    end
    
    it "should delete the token and expiration on 'forget_me!'" do
      create_new_user
      @user.remember_me!
      @user.remember_me_token.should_not be_nil
      @user.forget_me!
      @user.remember_me_token.should be_nil
      @user.remember_me_token_expires_at.should be_nil
    end
  end

end