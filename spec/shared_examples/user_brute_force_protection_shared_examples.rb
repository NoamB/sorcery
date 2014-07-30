shared_examples_for "rails_3_brute_force_protection_model" do
  let(:user) { create_new_user }
  before(:each) do
    User.sorcery_adapter.delete_all
  end


  context "loaded plugin configuration" do

    let(:config) { User.sorcery_config }

    before(:all) do
      sorcery_reload!([:brute_force_protection])
    end

    after(:each) do
      User.sorcery_config.reset!
    end

    specify { expect(user).to respond_to(:failed_logins_count) }
    specify { expect(user).to respond_to(:lock_expires_at) }

    it "enables configuration option 'failed_logins_count_attribute_name'" do
      sorcery_model_property_set(:failed_logins_count_attribute_name, :my_count)
      expect(config.failed_logins_count_attribute_name).to eq :my_count
    end

    it "enables configuration option 'lock_expires_at_attribute_name'" do
      sorcery_model_property_set(:lock_expires_at_attribute_name, :expires)
      expect(config.lock_expires_at_attribute_name).to eq :expires
    end

    it "enables configuration option 'consecutive_login_retries_amount_allowed'" do
      sorcery_model_property_set(:consecutive_login_retries_amount_limit, 34)
      expect(config.consecutive_login_retries_amount_limit).to eq 34
    end

    it "enables configuration option 'login_lock_time_period'" do
      sorcery_model_property_set(:login_lock_time_period, 2.hours)
      expect(config.login_lock_time_period).to eq 2.hours
    end

    describe "#locked?" do
      it "is locked" do
        user.send("#{config.lock_expires_at_attribute_name}=", Time.now + 5.days)
        expect(user).to be_locked
      end

      it "isn't locked" do
        user.send("#{config.lock_expires_at_attribute_name}=", nil)
        expect(user).not_to be_locked
      end
    end
  end

  describe "#register_failed_login!" do
    it "locks user when number of retries reached the limit" do
      expect(user.lock_expires_at).to be_nil

      sorcery_model_property_set(:consecutive_login_retries_amount_limit, 1)
      user.register_failed_login!
      lock_expires_at = User.sorcery_adapter.find_by_id(user.id).lock_expires_at

      expect(lock_expires_at).not_to be_nil
    end

    context "unlock_token_mailer_disabled is true" do
      it "does not automatically send unlock email" do
        sorcery_model_property_set(:unlock_token_mailer_disabled, true)
        sorcery_model_property_set(:consecutive_login_retries_amount_limit, 2)
        sorcery_model_property_set(:login_lock_time_period, 0)
        sorcery_model_property_set(:unlock_token_mailer, SorceryMailer)

        3.times { user.register_failed_login! }

        expect(ActionMailer::Base.deliveries.size).to eq 0

      end
    end

    context "unlock_token_mailer_disabled is false" do
      before do
        sorcery_model_property_set(:unlock_token_mailer_disabled, false)
        sorcery_model_property_set(:consecutive_login_retries_amount_limit, 2)
        sorcery_model_property_set(:login_lock_time_period, 0)
        sorcery_model_property_set(:unlock_token_mailer, SorceryMailer)
      end

      it "does not automatically send unlock email" do
        3.times { user.register_failed_login! }

        expect(ActionMailer::Base.deliveries.size).to eq 1
      end

      it "generates unlock token before mail is sent" do
        3.times { user.register_failed_login! }

        expect(ActionMailer::Base.deliveries.last.body.to_s.match(user.unlock_token)).not_to be_nil
      end
    end
  end

  context ".authenticate" do

    it "unlocks after lock time period passes" do
      sorcery_model_property_set(:consecutive_login_retries_amount_limit, 2)
      sorcery_model_property_set(:login_lock_time_period, 0.2)
      2.times { user.register_failed_login! }

      lock_expires_at = User.sorcery_adapter.find_by_id(user.id).lock_expires_at
      expect(lock_expires_at).not_to be_nil

      Timecop.travel(Time.now.in_time_zone + 0.3)
      User.authenticate('bla@bla.com', 'secret')

      lock_expires_at = User.sorcery_adapter.find_by_id(user.id).lock_expires_at
      expect(lock_expires_at).to be_nil
      Timecop.return
    end

    it "doest not unlock if time period is 0 (permanent lock)" do
      sorcery_model_property_set(:consecutive_login_retries_amount_limit, 2)
      sorcery_model_property_set(:login_lock_time_period, 0)

      2.times { user.register_failed_login! }

      unlock_date = user.lock_expires_at
      Timecop.travel(Time.now.in_time_zone + 1)

      user.register_failed_login!

      expect(user.lock_expires_at.to_s).to eq unlock_date.to_s
      Timecop.return
    end

  end

  describe "#unlock!" do
    it "unlocks after entering unlock token" do
      sorcery_model_property_set(:consecutive_login_retries_amount_limit, 2)
      sorcery_model_property_set(:login_lock_time_period, 0)
      sorcery_model_property_set(:unlock_token_mailer, SorceryMailer)
      3.times { user.register_failed_login! }

      expect(user.unlock_token).not_to be_nil

      token = user.unlock_token
      user = User.load_from_unlock_token(token)

      expect(user).not_to be_nil

      user.unlock!
      expect(User.load_from_unlock_token(user.unlock_token)).to be_nil
    end
  end
end
