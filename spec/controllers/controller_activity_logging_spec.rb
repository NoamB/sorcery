require 'spec_helper'

# require 'shared_examples/controller_activity_logging_shared_examples'

describe SorceryController do
  after(:all) do
    sorcery_controller_property_set(:register_login_time, true)
    sorcery_controller_property_set(:register_logout_time, true)
    sorcery_controller_property_set(:register_last_activity_time, true)
    # sorcery_controller_property_set(:last_login_from_ip_address_name, true)
  end

  # ----------------- ACTIVITY LOGGING -----------------------
  context "with activity logging features" do

    let(:adapter) { double('sorcery_adapter') }
    let(:user) { double('user', id: 42, sorcery_adapter: adapter) }

    before(:all) do
      sorcery_reload!([:activity_logging])
    end

    specify { expect(subject).to respond_to(:current_users) }

    before(:each) do
      allow(user).to receive(:username)
      allow(user).to receive_message_chain(:sorcery_config, :username_attribute_names, :first) { :username }
      allow(User.sorcery_config).to receive(:last_login_at_attribute_name) { :last_login_at }
      allow(User.sorcery_config).to receive(:last_login_from_ip_address_name) { :last_login_from_ip_address }

      sorcery_controller_property_set(:register_login_time, false)
      sorcery_controller_property_set(:register_last_ip_address, false)
      sorcery_controller_property_set(:register_last_activity_time, false)
    end

    it "'current_users' should proxy to User.current_users" do
      expect(User).to receive(:current_users).with(no_args)

      subject.current_users
    end


    it "logs login time on login" do
      now = Time.now.in_time_zone
      Timecop.freeze(now)

      sorcery_controller_property_set(:register_login_time, true)
      expect(user).to receive(:set_last_login_at).with(be_within(0.1).of(now))
      login_user(user)

      Timecop.return
    end

    it "logs logout time on logout" do
      login_user(user)
      now = Time.now.in_time_zone
      Timecop.freeze(now)
      expect(user).to receive(:set_last_logout_at).with(be_within(0.1).of(now))

      logout_user

      Timecop.return
    end

    it "logs last activity time when logged in" do
      sorcery_controller_property_set(:register_last_activity_time, true)

      login_user(user)
      now = Time.now.in_time_zone
      Timecop.freeze(now)
      expect(user).to receive(:set_last_activity_at).with(be_within(0.1).of(now))

      get :some_action

      Timecop.return
    end

    it "logs last IP address when logged in" do
      sorcery_controller_property_set(:register_last_ip_address, true)
      expect(user).to receive(:set_last_ip_addess).with('0.0.0.0')

      login_user(user)
    end

    it "updates nothing but activity fields" do
      pending 'Move to model'
      original_user_name = User.last.username
      login_user(user)
      get :some_action_making_a_non_persisted_change_to_the_user

      expect(User.last.username).to eq original_user_name
    end

    it "does not register login time if configured so" do
      sorcery_controller_property_set(:register_login_time, false)

      expect(user).to receive(:set_last_login_at).never
      login_user(user)
    end

    it "does not register logout time if configured so" do
      sorcery_controller_property_set(:register_logout_time, false)
      login_user(user)

      expect(user).to receive(:set_last_logout_at).never
      logout_user
    end

    it "does not register last activity time if configured so" do
      sorcery_controller_property_set(:register_last_activity_time, false)

      expect(user).to receive(:set_last_activity_at).never
      login_user(user)
    end

    it "does not register last IP address if configured so" do
      sorcery_controller_property_set(:register_last_ip_address, false)
      expect(user).to receive(:set_last_ip_addess).never

      login_user(user)
    end

  end
end
