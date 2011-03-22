require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "User with remember_me submodule" do
  before(:all) do
    ActiveRecord::Migrator.migrate("#{APP_ROOT}/db/migrate/remember_me")
  end
  
  after(:all) do
    ActiveRecord::Migrator.rollback("#{APP_ROOT}/db/migrate/remember_me")
  end

  # ----------------- PLUGIN CONFIGURATION -----------------------
  describe User, "loaded plugin configuration" do
    before(:all) do
      sorcery_reload!([:remember_me])
    end
  
    after(:each) do
      User.sorcery_config.reset!
    end
    
    it "should allow configuration option 'remember_me_token_attribute_name'" do
      sorcery_model_property_set(:remember_me_token_attribute_name, :my_token)
      User.sorcery_config.remember_me_token_attribute_name.should equal(:my_token)
    end

    it "should allow configuration option 'remember_me_token_expires_at_attribute_name'" do
      sorcery_model_property_set(:remember_me_token_expires_at_attribute_name, :my_expires)
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
      sorcery_model_property_set(:remember_me_for, 2 * 60 * 60 * 24)
      @user.remember_me!
      @user.remember_me_token_expires_at.to_s.should == (Time.now + 2 * 60 * 60 * 24).to_s
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