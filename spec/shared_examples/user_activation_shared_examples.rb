shared_examples_for "rails_3_activation_model" do
  # ----------------- PLUGIN CONFIGURATION -----------------------
  describe User, "loaded plugin configuration" do
    before(:all) do
      sorcery_reload!([:user_activation], :user_activation_mailer => ::SorceryMailer)
    end

    after(:each) do
      User.sorcery_config.reset!
      sorcery_reload!([:user_activation], :user_activation_mailer => ::SorceryMailer)
    end

    it "should enable configuration option 'activation_state_attribute_name'" do
      sorcery_model_property_set(:activation_state_attribute_name, :status)
      User.sorcery_config.activation_state_attribute_name.should equal(:status)
    end

    it "should enable configuration option 'activation_token_attribute_name'" do
      sorcery_model_property_set(:activation_token_attribute_name, :code)
      User.sorcery_config.activation_token_attribute_name.should equal(:code)
    end

    it "should enable configuration option 'user_activation_mailer'" do
      sorcery_model_property_set(:user_activation_mailer, TestMailer)
      User.sorcery_config.user_activation_mailer.should equal(TestMailer)
    end

    it "should enable configuration option 'activation_needed_email_method_name'" do
      sorcery_model_property_set(:activation_needed_email_method_name, :my_activation_email)
      User.sorcery_config.activation_needed_email_method_name.should equal(:my_activation_email)
    end

    it "should enable configuration option 'activation_success_email_method_name'" do
      sorcery_model_property_set(:activation_success_email_method_name, :my_activation_email)
      User.sorcery_config.activation_success_email_method_name.should equal(:my_activation_email)
    end

    it "should enable configuration option 'activation_mailer_disabled'" do
      sorcery_model_property_set(:activation_mailer_disabled, :my_activation_mailer_disabled)
      User.sorcery_config.activation_mailer_disabled.should equal(:my_activation_mailer_disabled)
    end

    it "if mailer is nil and mailer is enabled, throw exception!" do
      expect{sorcery_reload!([:user_activation], :activation_mailer_disabled => false)}.to raise_error(ArgumentError)
    end

    it "if mailer is disabled and mailer is nil, do NOT throw exception" do
      expect{sorcery_reload!([:user_activation], :activation_mailer_disabled => true)}.to_not raise_error
    end
  end

  # ----------------- ACTIVATION PROCESS -----------------------
  describe User, "activation process" do
    before(:all) do
      sorcery_reload!([:user_activation], :user_activation_mailer => ::SorceryMailer)
    end

    before(:each) do
      create_new_user
    end

    it "should initialize user state to 'pending'" do
      @user.activation_state.should == "pending"
    end

    specify { @user.should respond_to(:activate!) }

    it "should clear activation code and change state to 'active' on activation" do
      activation_token = @user.activation_token
      @user.activate!
      @user2 = User.find(@user.id) # go to db to make sure it was saved and not just in memory
      @user2.activation_token.should be_nil
      @user2.activation_state.should == "active"
      User.find_by_activation_token(activation_token).should be_nil
    end


    context "mailer is enabled" do
      it "should send the user an activation email" do
        old_size = ActionMailer::Base.deliveries.size
        create_new_user
        ActionMailer::Base.deliveries.size.should == old_size + 1
      end

      it "should call send_activation_needed_email! method of user" do
        user = build_new_user
        user.should_receive(:send_activation_needed_email!).once
        user.save!
      end

      it "subsequent saves do not send activation email" do
        old_size = ActionMailer::Base.deliveries.size
        @user.email = "Shauli"
        @user.save!
        ActionMailer::Base.deliveries.size.should == old_size
      end

      it "should send the user an activation success email on successful activation" do
        old_size = ActionMailer::Base.deliveries.size
        @user.activate!
        ActionMailer::Base.deliveries.size.should == old_size + 1
      end

      it "should call send_activation_success_email! method of user on activation" do
        @user.should_receive(:send_activation_success_email!).once
        @user.activate!
      end

      it "subsequent saves do not send activation success email" do
        @user.activate!
        old_size = ActionMailer::Base.deliveries.size
        @user.email = "Shauli"
        @user.save!
        ActionMailer::Base.deliveries.size.should == old_size
      end

      it "activation needed email is optional" do
        sorcery_model_property_set(:activation_needed_email_method_name, nil)
        old_size = ActionMailer::Base.deliveries.size
        create_new_user
        ActionMailer::Base.deliveries.size.should == old_size
      end

      it "activation success email is optional" do
        sorcery_model_property_set(:activation_success_email_method_name, nil)
        old_size = ActionMailer::Base.deliveries.size
        @user.activate!
        ActionMailer::Base.deliveries.size.should == old_size
      end
    end

    context "mailer has been disabled" do
      before(:each) do
        sorcery_reload!([:user_activation], :activation_mailer_disabled => true, :user_activation_mailer => ::SorceryMailer)
      end

      it "should not send the user an activation email" do
        old_size = ActionMailer::Base.deliveries.size
        create_new_user
        ActionMailer::Base.deliveries.size.should == old_size
      end

      it "should not call send_activation_needed_email! method of user" do
        user = build_new_user
        user.should_receive(:send_activation_needed_email!).never
        user.save!
      end

      it "should not send the user an activation success email on successful activation" do
        old_size = ActionMailer::Base.deliveries.size
        @user.activate!
        ActionMailer::Base.deliveries.size.should == old_size
      end

      it "should call send_activation_success_email! method of user on activation" do
        @user.should_receive(:send_activation_success_email!).never
        @user.activate!
      end
    end
  end

  describe User, "prevent non-active login feature" do
    before(:all) do
      sorcery_reload!([:user_activation], :user_activation_mailer => ::SorceryMailer)
    end

    before(:each) do
      User.delete_all
      create_new_user
    end

    it "should not allow a non-active user to authenticate" do
      User.authenticate(@user.email, 'secret').should be_false
    end

    it "should allow a non-active user to authenticate if configured so" do
      sorcery_model_property_set(:prevent_non_active_users_to_login, false)
      User.authenticate(@user.email, 'secret').should be_true
    end
  end

  describe User, "load_from_activation_token" do
    before(:all) do
      sorcery_reload!([:user_activation], :user_activation_mailer => ::SorceryMailer)
    end

    after(:each) do
      Timecop.return
    end

    it "load_from_activation_token should return user when token is found" do
      create_new_user
      User.load_from_activation_token(@user.activation_token).should == @user
    end

    it "load_from_activation_token should NOT return user when token is NOT found" do
      create_new_user
      User.load_from_activation_token("a").should == nil
    end

    it "load_from_activation_token should return user when token is found and not expired" do
      sorcery_model_property_set(:activation_token_expiration_period, 500)
      create_new_user
      User.load_from_activation_token(@user.activation_token).should == @user
    end

    it "load_from_activation_token should NOT return user when token is found and expired" do
      sorcery_model_property_set(:activation_token_expiration_period, 0.1)
      create_new_user
      Timecop.travel(Time.now.in_time_zone+0.5)
      User.load_from_activation_token(@user.activation_token).should == nil
    end

    it "load_from_activation_token should return nil if token is blank" do
      User.load_from_activation_token(nil).should == nil
      User.load_from_activation_token("").should == nil
    end

    it "load_from_activation_token should always be valid if expiration period is nil" do
      sorcery_model_property_set(:activation_token_expiration_period, nil)
      create_new_user
      User.load_from_activation_token(@user.activation_token).should == @user
    end
  end
end