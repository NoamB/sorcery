shared_examples_for "rails_3_approval_model" do
  let(:user) { create_new_user }
  let(:new_user) { build_new_user }

  context "loaded plugin configuration" do
    before(:all) do
      sorcery_reload!([:user_approval], :user_approval_mailer => ::SorceryMailer)
    end

    after(:each) do
      User.sorcery_config.reset!
      sorcery_reload!([:user_approval], :user_approval_mailer => ::SorceryMailer)
    end

    it "enables configuration option 'approval_state_attribute_name'" do
      sorcery_model_property_set(:approval_state_attribute_name, :status)

      expect(User.sorcery_config.approval_state_attribute_name).to eq :status
    end

    it "enables configuration option 'user_approval_mailer'" do
      sorcery_model_property_set(:user_approval_mailer, TestMailer)

      expect(User.sorcery_config.user_approval_mailer).to equal(TestMailer)
    end

    it "enables configuration option 'waiting_approval_email_method_name'" do
      sorcery_model_property_set(:waiting_approval_email_method_name, :my_approval_email)

      expect(User.sorcery_config.waiting_approval_email_method_name).to eq :my_approval_email
    end

    it "enables configuration option 'approval_success_email_method_name'" do
      sorcery_model_property_set(:approval_success_email_method_name, :my_approval_email)

      expect(User.sorcery_config.approval_success_email_method_name).to eq :my_approval_email
    end

    it "enables configuration option 'approval_mailer_disabled'" do
      sorcery_model_property_set(:approval_mailer_disabled, :my_approval_mailer_disabled)

      expect(User.sorcery_config.approval_mailer_disabled).to eq :my_approval_mailer_disabled
    end

    it "if mailer is nil and mailer is enabled, throw exception!" do
      expect{sorcery_reload!([:user_approval], :approval_mailer_disabled => false)}.to raise_error(ArgumentError)
    end

    it "if mailer is disabled and mailer is nil, do NOT throw exception" do
      expect{sorcery_reload!([:user_approval], :approval_mailer_disabled => true)}.to_not raise_error
    end
  end


  context "approval process" do
    before(:all) do
      sorcery_reload!([:user_approval], :user_approval_mailer => ::SorceryMailer)
    end

    it "initializes user state to 'waiting'" do
      expect(user.approval_state).to eq "waiting"
    end

    specify { expect(user).to respond_to :approve! }

    it "change state to 'approved' on approval" do
      user.approve!
      user2 = User.sorcery_adapter.find(user.id) # go to db to make sure it was saved and not just in memory

      expect(user2.approval_state).to eq "approved"
    end

    context "mailer is enabled" do
      it "sends the user a waiting approval email" do
        old_size = ActionMailer::Base.deliveries.size
        create_new_user

        expect(ActionMailer::Base.deliveries.size).to eq old_size + 1
      end

      it "calls send_waiting_approval_email! method of user" do
        expect(new_user).to receive(:send_waiting_approval_email!).once

        new_user.sorcery_adapter.save(:raise_on_failure => true)
      end

      it "subsequent saves do not send approval email" do
        user
        old_size = ActionMailer::Base.deliveries.size
        user.email = "Shauli"
        user.sorcery_adapter.save(:raise_on_failure => true)

        expect(ActionMailer::Base.deliveries.size).to eq old_size
      end

      it "sends the user an approval success email on successful approval" do
        user
        old_size = ActionMailer::Base.deliveries.size
        user.approve!

        expect(ActionMailer::Base.deliveries.size).to eq old_size + 1
      end

      it "calles send_approval_success_email! method of user on approval" do
        expect(user).to receive(:send_approval_success_email!).once

        user.approve!
      end

      it "subsequent saves do not send approval success email" do
        user.approve!
        old_size = ActionMailer::Base.deliveries.size
        user.email = "Shauli"
        user.sorcery_adapter.save(:raise_on_failure => true)

        expect(ActionMailer::Base.deliveries.size).to eq old_size
      end

      it "waiting approval email is optional" do
        sorcery_model_property_set(:waiting_approval_email_method_name, nil)
        old_size = ActionMailer::Base.deliveries.size

        expect(ActionMailer::Base.deliveries.size).to eq old_size
      end

      it "approval success email is optional" do
        sorcery_model_property_set(:approval_success_email_method_name, nil)
        old_size = ActionMailer::Base.deliveries.size

        expect(ActionMailer::Base.deliveries.size).to eq old_size
      end
    end

    context "mailer has been disabled" do
      before(:each) do
        sorcery_reload!([:user_approval], :approval_mailer_disabled => true, :user_approval_mailer => ::SorceryMailer)
      end

      it "does not send the user an approval email" do
        old_size = ActionMailer::Base.deliveries.size

        expect(ActionMailer::Base.deliveries.size).to eq old_size
      end

      it "does not call send_waiting_approval_email! method of user" do
        user = build_new_user

        expect(user).to receive(:send_waiting_approval_email!).never

        user.sorcery_adapter.save(:raise_on_failure => true)
      end

      it "does not send user an approval success email on successful approval" do
        old_size = ActionMailer::Base.deliveries.size
        user.approve!

        expect(ActionMailer::Base.deliveries.size).to eq old_size
      end

      it "does not call send_approval_success_email! method of user of approval" do
        expect(user).to receive(:send_approval_success_email!).never

        user.approve!
      end
    end
  end

  describe "prevent not-approved login feature" do
    before(:all) do
      sorcery_reload!([:user_approval], :user_approval_mailer => ::SorceryMailer)
    end

    before(:each) do
      User.sorcery_adapter.delete_all
    end

    it "does not allow a not-approved user to authenticate" do
      expect(User.authenticate user.email, 'secret').to be_falsy
    end

    it "allows a not-approved user to authenticate if configured so" do
      sorcery_model_property_set(:prevent_not_approved_users_to_login, false)

      expect(User.authenticate user.email, 'secret').to be_truthy
    end
  end
end
