require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "User with reset_password submodule" do
  before(:all) do
    ActiveRecord::Migrator.migrate("#{Rails.root}/db/migrate/reset_password")
  end
  
  after(:all) do
    ActiveRecord::Migrator.rollback("#{Rails.root}/db/migrate/reset_password")
  end

  # ----------------- PLUGIN CONFIGURATION -----------------------
  describe User, "loaded plugin configuration" do
  
    before(:all) do
      plugin_model_configure([:reset_password], :reset_password_mailer => ::SorceryMailer)
    end
  
    after(:each) do
      User.sorcery_config.reset!
    end
    
    it "should respond to 'deliver_reset_password_instructions!'" do
      create_new_user
      @user.should respond_to(:deliver_reset_password_instructions!)
    end
    
    it "should respond to 'reset_password_token_valid?'" do
      create_new_user
      @user.should respond_to(:reset_password_token_valid?)
    end
    
    it "should respond to 'reset_password!" do
      create_new_user
      @user.should respond_to(:reset_password!)
    end
    
    it "should respond to 'load_from_reset_password_token'" do
      create_new_user
      User.should respond_to(:load_from_reset_password_token)
    end
    
    it "should allow configuration option 'reset_password_token_attribute_name'" do
      plugin_set_model_config_property(:reset_password_token_attribute_name, :my_code)
      User.sorcery_config.reset_password_token_attribute_name.should equal(:my_code)
    end
    
    it "should allow configuration option 'reset_password_mailer'" do
      plugin_set_model_config_property(:reset_password_mailer, TestUser)
      User.sorcery_config.reset_password_mailer.should equal(TestUser)
    end
    
    it "should allow configuration option 'reset_password_email_method_name'" do
      plugin_set_model_config_property(:reset_password_email_method_name, :my_mailer_method)
      User.sorcery_config.reset_password_email_method_name.should equal(:my_mailer_method)
    end
    
    it "should allow configuration option 'reset_password_expiration_period'" do
      plugin_set_model_config_property(:reset_password_expiration_period, 16)
      User.sorcery_config.reset_password_expiration_period.should equal(16)
    end
    
    it "should allow configuration option 'reset_password_email_sent_at_attribute_name'" do
      plugin_set_model_config_property(:reset_password_email_sent_at_attribute_name, :blabla)
      User.sorcery_config.reset_password_email_sent_at_attribute_name.should equal(:blabla)
    end
    
    it "should allow configuration option 'reset_password_time_between_emails'" do
      plugin_set_model_config_property(:reset_password_time_between_emails, 16)
      User.sorcery_config.reset_password_time_between_emails.should equal(16)
    end
  end

  # ----------------- PLUGIN ACTIVATED -----------------------
  describe User, "when activated with sorcery" do
  
    before(:all) do
      plugin_model_configure([:reset_password], :reset_password_mailer => ::SorceryMailer)
    end
  
    before(:each) do
      User.delete_all
    end

    it "load_from_reset_password_token should return user when token is found" do
      create_new_user
      @user.deliver_reset_password_instructions!
      User.load_from_reset_password_token(@user.reset_password_token).should == @user
    end
    
    it "load_from_reset_password_token should NOT return user when token is NOT found" do
      create_new_user
      @user.deliver_reset_password_instructions!
      User.load_from_reset_password_token("a").should == nil
    end
    
    it "load_from_reset_password_token should return user when token is found and not expired" do
      create_new_user
      plugin_set_model_config_property(:reset_password_expiration_period, 500)
      @user.deliver_reset_password_instructions!
      User.load_from_reset_password_token(@user.reset_password_token).should == @user
    end
    
    it "load_from_reset_password_token should NOT return user when token is found and expired" do
      create_new_user
      plugin_set_model_config_property(:reset_password_expiration_period, 0.1)
      @user.deliver_reset_password_instructions!
      sleep 0.5
      User.load_from_reset_password_token(@user.reset_password_token).should == nil
    end
    
    it "load_from_reset_password_token should return nil if token is blank" do
      User.load_from_reset_password_token(nil).should == nil
      User.load_from_reset_password_token("").should == nil
    end
    
    it "'deliver_reset_password_instructions!' should generate a reset_password_token" do
      create_new_user
      @user.reset_password_token.should be_nil
      @user.deliver_reset_password_instructions!
      @user.reset_password_token.should_not be_nil
    end

    it "the reset_password_token should be random" do
      create_new_user
      plugin_set_model_config_property(:reset_password_time_between_emails, 0)
      @user.deliver_reset_password_instructions!
      old_password_code = @user.reset_password_token
      @user.deliver_reset_password_instructions!
      @user.reset_password_token.should_not == old_password_code
    end

    it "should send an email on reset" do
      create_new_user
      old_size = ActionMailer::Base.deliveries.size
      @user.deliver_reset_password_instructions!
      ActionMailer::Base.deliveries.size.should == old_size + 1
    end

    it "when reset_password! is called, should delete reset_password_token" do
      create_new_user
      @user.deliver_reset_password_instructions!
      @user.reset_password_token.should_not be_nil
      @user.reset_password!(:password => "blabulsdf")
      @user.save!
      @user.reset_password_token.should be_nil
    end
    
    it "code isn't valid if expiration passed" do
      create_new_user
      plugin_set_model_config_property(:reset_password_expiration_period, 0.1)
      @user.deliver_reset_password_instructions!
      sleep 0.5
      @user.reset_password_token_valid?.should == false
    end
    
    it "code is valid if it's the same code and expiration period did not pass" do
      create_new_user
      plugin_set_model_config_property(:reset_password_expiration_period, 300)
      @user.deliver_reset_password_instructions!
      @user.reset_password_token_valid?.should == true
    end
    
    it "code is valid if it's the same code and expiration period is nil" do
      create_new_user
      plugin_set_model_config_property(:reset_password_expiration_period, nil)
      @user.deliver_reset_password_instructions!
      @user.reset_password_token_valid?.should == true
    end
    
    it "should not send an email if time between emails has not passed since last email" do
      create_new_user
      plugin_set_model_config_property(:reset_password_time_between_emails, 10000)
      old_size = ActionMailer::Base.deliveries.size
      @user.deliver_reset_password_instructions!
      ActionMailer::Base.deliveries.size.should == old_size + 1
      @user.deliver_reset_password_instructions!
      ActionMailer::Base.deliveries.size.should == old_size + 1
    end
    
    it "should send an email if time between emails has passed since last email" do
      create_new_user
      plugin_set_model_config_property(:reset_password_time_between_emails, 0.5)
      old_size = ActionMailer::Base.deliveries.size
      @user.deliver_reset_password_instructions!
      ActionMailer::Base.deliveries.size.should == old_size + 1
      sleep 0.5
      @user.deliver_reset_password_instructions!
      ActionMailer::Base.deliveries.size.should == old_size + 2
    end
    
    it "if mailer is nil on activation, throw exception!" do
      expect{plugin_model_configure([:reset_password])}.to raise_error(ArgumentError)
    end
    
  end
  
end