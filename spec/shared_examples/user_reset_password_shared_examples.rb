shared_examples_for "rails_3_reset_password_model" do
  # ----------------- PLUGIN CONFIGURATION -----------------------
  describe User, "loaded plugin configuration" do
  
    before(:all) do
      sorcery_reload!([:reset_password], :reset_password_mailer => ::SorceryMailer)
    end
  
    after(:each) do
      User.sorcery_config.reset!
    end
    
    context "API" do
      before(:all) do
        create_new_user
      end
      
      specify { @user.should respond_to(:deliver_reset_password_instructions!) }
      
      specify { @user.should respond_to(:change_password!) }

      it "should respond to .load_from_reset_password_token" do
        User.should respond_to(:load_from_reset_password_token)
      end
    end

    it "should allow configuration option 'reset_password_token_attribute_name'" do
      sorcery_model_property_set(:reset_password_token_attribute_name, :my_code)
      User.sorcery_config.reset_password_token_attribute_name.should equal(:my_code)
    end
    
    it "should allow configuration option 'reset_password_mailer'" do
      sorcery_model_property_set(:reset_password_mailer, TestUser)
      User.sorcery_config.reset_password_mailer.should equal(TestUser)
    end

    it "should enable configuration option 'reset_password_mailer_disabled'" do
      sorcery_model_property_set(:reset_password_mailer_disabled, :my_reset_password_mailer_disabled)
      User.sorcery_config.reset_password_mailer_disabled.should equal(:my_reset_password_mailer_disabled)
    end
    
    it "if mailer is nil and mailer is enabled, throw exception!" do
      expect{sorcery_reload!([:reset_password], :reset_password_mailer_disabled => false)}.to raise_error(ArgumentError)
    end

    it "if mailer is disabled and mailer is nil, do NOT throw exception" do
      expect{sorcery_reload!([:reset_password], :reset_password_mailer_disabled => true)}.to_not raise_error
    end    

    it "should allow configuration option 'reset_password_email_method_name'" do
      sorcery_model_property_set(:reset_password_email_method_name, :my_mailer_method)
      User.sorcery_config.reset_password_email_method_name.should equal(:my_mailer_method)
    end
    
    it "should allow configuration option 'reset_password_expiration_period'" do
      sorcery_model_property_set(:reset_password_expiration_period, 16)
      User.sorcery_config.reset_password_expiration_period.should equal(16)
    end
    
    it "should allow configuration option 'reset_password_email_sent_at_attribute_name'" do
      sorcery_model_property_set(:reset_password_email_sent_at_attribute_name, :blabla)
      User.sorcery_config.reset_password_email_sent_at_attribute_name.should equal(:blabla)
    end
    
    it "should allow configuration option 'reset_password_time_between_emails'" do
      sorcery_model_property_set(:reset_password_time_between_emails, 16)
      User.sorcery_config.reset_password_time_between_emails.should equal(16)
    end
  end

  # ----------------- PLUGIN ACTIVATED -----------------------
  describe User, "when activated with sorcery" do
  
    before(:all) do
      sorcery_reload!([:reset_password], :reset_password_mailer => ::SorceryMailer)
    end
  
    before(:each) do
      User.delete_all
    end
    
    after(:each) do
      Timecop.return
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
      sorcery_model_property_set(:reset_password_expiration_period, 500)
      @user.deliver_reset_password_instructions!
      User.load_from_reset_password_token(@user.reset_password_token).should == @user
    end
    
    it "load_from_reset_password_token should NOT return user when token is found and expired" do
      create_new_user
      sorcery_model_property_set(:reset_password_expiration_period, 0.1)
      @user.deliver_reset_password_instructions!
      Timecop.travel(Time.now.in_time_zone+0.5)
      User.load_from_reset_password_token(@user.reset_password_token).should == nil
    end
    
    it "load_from_reset_password_token should always be valid if expiration period is nil" do
      create_new_user
      sorcery_model_property_set(:reset_password_expiration_period, nil)
      @user.deliver_reset_password_instructions!
      User.load_from_reset_password_token(@user.reset_password_token).should == @user
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
      sorcery_model_property_set(:reset_password_time_between_emails, 0)
      @user.deliver_reset_password_instructions!
      old_password_code = @user.reset_password_token
      @user.deliver_reset_password_instructions!
      @user.reset_password_token.should_not == old_password_code
    end

    context "mailer is enabled" do
      it "should send an email on reset" do
        create_new_user
        old_size = ActionMailer::Base.deliveries.size
        @user.deliver_reset_password_instructions!
        ActionMailer::Base.deliveries.size.should == old_size + 1
      end

      it "should not send an email if time between emails has not passed since last email" do
        create_new_user
        sorcery_model_property_set(:reset_password_time_between_emails, 10000)
        old_size = ActionMailer::Base.deliveries.size
        @user.deliver_reset_password_instructions!
        ActionMailer::Base.deliveries.size.should == old_size + 1
        @user.deliver_reset_password_instructions!
        ActionMailer::Base.deliveries.size.should == old_size + 1
      end

      it "should send an email if time between emails has passed since last email" do
        create_new_user
        sorcery_model_property_set(:reset_password_time_between_emails, 0.5)
        old_size = ActionMailer::Base.deliveries.size
        @user.deliver_reset_password_instructions!
        ActionMailer::Base.deliveries.size.should == old_size + 1
        Timecop.travel(Time.now.in_time_zone+0.5)
        @user.deliver_reset_password_instructions!
        ActionMailer::Base.deliveries.size.should == old_size + 2
      end
    end

    context "mailer is disabled" do

      before(:all) do
        sorcery_reload!([:reset_password], :reset_password_mailer_disabled => true, :reset_password_mailer => ::SorceryMailer)
      end

      it "should send an email on reset" do
        create_new_user
        old_size = ActionMailer::Base.deliveries.size
        @user.deliver_reset_password_instructions!
        ActionMailer::Base.deliveries.size.should == old_size
      end

      it "should not send an email if time between emails has not passed since last email" do
        create_new_user
        sorcery_model_property_set(:reset_password_time_between_emails, 10000)
        old_size = ActionMailer::Base.deliveries.size
        @user.deliver_reset_password_instructions!
        ActionMailer::Base.deliveries.size.should == old_size
        @user.deliver_reset_password_instructions!
        ActionMailer::Base.deliveries.size.should == old_size
      end

      it "should send an email if time between emails has passed since last email" do
        create_new_user
        sorcery_model_property_set(:reset_password_time_between_emails, 0.5)
        old_size = ActionMailer::Base.deliveries.size
        @user.deliver_reset_password_instructions!
        ActionMailer::Base.deliveries.size.should == old_size
        Timecop.travel(Time.now.in_time_zone+0.5)
        @user.deliver_reset_password_instructions!
        ActionMailer::Base.deliveries.size.should == old_size
      end
    end

    it "when change_password! is called, should delete reset_password_token" do
      create_new_user
      @user.deliver_reset_password_instructions!
      @user.reset_password_token.should_not be_nil
      @user.change_password!("blabulsdf")
      @user.save!
      @user.reset_password_token.should be_nil
    end

    it "should return false if time between emails has not passed since last email" do
      create_new_user
      sorcery_model_property_set(:reset_password_time_between_emails, 10000)
      @user.deliver_reset_password_instructions!
      @user.deliver_reset_password_instructions!.should == false
    end

    it "should encrypt properly on reset" do
      create_new_user
      @user.deliver_reset_password_instructions!
      @user.change_password!("blagu")
      Sorcery::CryptoProviders::BCrypt.matches?(@user.crypted_password,"blagu",@user.salt).should be_true
    end

  end
end
