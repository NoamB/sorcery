shared_examples_for "rails_3_activation_model" do
  let(:user) { create_new_user }
  let(:new_user) { build_new_user }

  context "loaded plugin configuration" do
    before(:all) do
      sorcery_reload!([:user_activation], :user_activation_mailer => ::SorceryMailer)
    end

    after(:each) do
      User.sorcery_config.reset!
      sorcery_reload!([:user_activation], :user_activation_mailer => ::SorceryMailer)
    end

    it "enables configuration option 'activation_state_attribute_name'" do
      sorcery_model_property_set(:activation_state_attribute_name, :status)

      expect(User.sorcery_config.activation_state_attribute_name).to eq :status
    end

    it "enables configuration option 'activation_token_attribute_name'" do
      sorcery_model_property_set(:activation_token_attribute_name, :code)

      expect(User.sorcery_config.activation_token_attribute_name).to eql :code
    end

    it "enables configuration option 'user_activation_mailer'" do
      sorcery_model_property_set(:user_activation_mailer, TestMailer)

      expect(User.sorcery_config.user_activation_mailer).to equal(TestMailer)
    end

    it "enables configuration option 'activation_needed_email_method_name'" do
      sorcery_model_property_set(:activation_needed_email_method_name, :my_activation_email)

      expect(User.sorcery_config.activation_needed_email_method_name).to eq :my_activation_email
    end

    it "enables configuration option 'activation_success_email_method_name'" do
      sorcery_model_property_set(:activation_success_email_method_name, :my_activation_email)

      expect(User.sorcery_config.activation_success_email_method_name).to eq :my_activation_email
    end

    it "enables configuration option 'activation_mailer_disabled'" do
      sorcery_model_property_set(:activation_mailer_disabled, :my_activation_mailer_disabled)

      expect(User.sorcery_config.activation_mailer_disabled).to eq :my_activation_mailer_disabled
    end

    it "if mailer is nil and mailer is enabled, throw exception!" do
      expect{sorcery_reload!([:user_activation], :activation_mailer_disabled => false)}.to raise_error(ArgumentError)
    end

    it "if mailer is disabled and mailer is nil, do NOT throw exception" do
      expect{sorcery_reload!([:user_activation], :activation_mailer_disabled => true)}.to_not raise_error
    end
  end


  context "activation process" do
    before(:all) do
      sorcery_reload!([:user_activation], :user_activation_mailer => ::SorceryMailer)
    end

    it "initializes user state to 'pending'" do
      expect(user.activation_state).to eq "pending"
    end

    specify { expect(user).to respond_to :activate! }

    it "clears activation code and change state to 'active' on activation" do
      activation_token = user.activation_token
      user.activate!
      user2 = User.sorcery_adapter.find(user.id) # go to db to make sure it was saved and not just in memory

      expect(user2.activation_token).to be_nil
      expect(user2.activation_state).to eq "active"
      expect(User.sorcery_adapter.find_by_activation_token activation_token).to be_nil
    end


    context "mailer is enabled" do
      it "sends the user an activation email" do
        old_size = ActionMailer::Base.deliveries.size
        create_new_user

        expect(ActionMailer::Base.deliveries.size).to eq old_size + 1
      end

      it "calls send_activation_needed_email! method of user" do
        expect(new_user).to receive(:send_activation_needed_email!).once

        new_user.sorcery_adapter.save(:raise_on_failure => true)
      end

      it "subsequent saves do not send activation email" do
        user
        old_size = ActionMailer::Base.deliveries.size
        user.email = "Shauli"
        user.sorcery_adapter.save(:raise_on_failure => true)

        expect(ActionMailer::Base.deliveries.size).to eq old_size
      end

      it "sends the user an activation success email on successful activation" do
        user
        old_size = ActionMailer::Base.deliveries.size
        user.activate!

        expect(ActionMailer::Base.deliveries.size).to eq old_size + 1
      end

      it "calls send_activation_success_email! method of user on activation" do
        expect(user).to receive(:send_activation_success_email!).once

        user.activate!
      end

      it "subsequent saves do not send activation success email" do
        user.activate!
        old_size = ActionMailer::Base.deliveries.size
        user.email = "Shauli"
        user.sorcery_adapter.save(:raise_on_failure => true)

        expect(ActionMailer::Base.deliveries.size).to eq old_size
      end

      it "activation needed email is optional" do
        sorcery_model_property_set(:activation_needed_email_method_name, nil)
        old_size = ActionMailer::Base.deliveries.size

        expect(ActionMailer::Base.deliveries.size).to eq old_size
      end

      it "activation success email is optional" do
        sorcery_model_property_set(:activation_success_email_method_name, nil)
        old_size = ActionMailer::Base.deliveries.size
        user.activate!

        expect(ActionMailer::Base.deliveries.size).to eq old_size
      end
    end

    context "mailer has been disabled" do
      before(:each) do
        sorcery_reload!([:user_activation], :activation_mailer_disabled => true, :user_activation_mailer => ::SorceryMailer)
      end

      it "does not send the user an activation email" do
        old_size = ActionMailer::Base.deliveries.size

        expect(ActionMailer::Base.deliveries.size).to eq old_size
      end

      it "does not call send_activation_needed_email! method of user" do
        user = build_new_user

        expect(user).to receive(:send_activation_needed_email!).never

        user.sorcery_adapter.save(:raise_on_failure => true)
      end

      it "does not send the user an activation success email on successful activation" do
        old_size = ActionMailer::Base.deliveries.size
        user.activate!

        expect(ActionMailer::Base.deliveries.size).to eq old_size
      end

      it "calls send_activation_success_email! method of user on activation" do
        expect(user).to receive(:send_activation_success_email!).never

        user.activate!
      end
    end
  end

  describe "prevent non-active login feature" do
    before(:all) do
      sorcery_reload!([:user_activation], :user_activation_mailer => ::SorceryMailer)
    end

    before(:each) do
      User.sorcery_adapter.delete_all
    end

    it "does not allow a non-active user to authenticate" do
      expect(User.authenticate user.email, 'secret').to be_falsy
    end

    it "allows a non-active user to authenticate if configured so" do
      sorcery_model_property_set(:prevent_non_active_users_to_login, false)

      expect(User.authenticate user.email, 'secret').to be_truthy
    end
  end

  describe "load_from_activation_token" do
    before(:all) do
      sorcery_reload!([:user_activation], :user_activation_mailer => ::SorceryMailer)
    end

    after(:each) do
      Timecop.return
    end

    it "load_from_activation_token returns user when token is found" do
      expect(User.load_from_activation_token user.activation_token).to eq user
    end

    it "load_from_activation_token does NOT return user when token is NOT found" do
      expect(User.load_from_activation_token "a").to be_nil
    end

    it "load_from_activation_token returas user when token is found and not expired" do
      sorcery_model_property_set(:activation_token_expiration_period, 500)

      expect(User.load_from_activation_token user.activation_token).to eq user
    end

    it "load_from_activation_token does NOT return user when token is found and expired" do
      sorcery_model_property_set(:activation_token_expiration_period, 0.1)
      user

      Timecop.travel(Time.now.in_time_zone+0.5)

      expect(User.load_from_activation_token user.activation_token).to be_nil
    end

    it "load_from_activation_token returns nil if token is blank" do
      expect(User.load_from_activation_token nil).to be_nil
      expect(User.load_from_activation_token "").to be_nil
    end

    it "load_from_activation_token is always valid if expiration period is nil" do
      sorcery_model_property_set(:activation_token_expiration_period, nil)

      expect(User.load_from_activation_token user.activation_token).to eq user
    end
  end
end
