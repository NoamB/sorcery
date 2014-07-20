require 'spec_helper'

# require 'shared_examples/controller_activity_logging_shared_examples'

describe SorceryController do
  before(:all) do
    if SORCERY_ORM == :active_record
      ActiveRecord::Migrator.migrate("#{Rails.root}/db/migrate/activity_logging")
      User.reset_column_information
    end
  end

  after(:all) do
    if SORCERY_ORM == :active_record
      ActiveRecord::Migrator.rollback("#{Rails.root}/db/migrate/activity_logging")
    end

    sorcery_controller_property_set(:register_login_time, true)
    sorcery_controller_property_set(:register_logout_time, true)
    sorcery_controller_property_set(:register_last_activity_time, true)
    # sorcery_controller_property_set(:last_login_from_ip_address_name, true)
  end

  # ----------------- ACTIVITY LOGGING -----------------------
  context "with activity logging features" do
    after(:each) do
      User.sorcery_adapter.delete_all

      if SORCERY_ORM == :data_mapper
        Authentication.sorcery_adapter.delete_all
      end
    end

    before(:all) do
      sorcery_reload!([:activity_logging])
    end

    specify { expect(subject).to respond_to(:current_users) }
    let(:user) { create_new_user }

    before(:each) { user }

    it "'current_users' is empty when no users are logged in" do
      expect(subject.current_users.size).to eq 0
    end

    it "logs login time on login" do
      now = Time.now.in_time_zone
      login_user

      expect(user.last_login_at).not_to be_nil
      expect(user.last_login_at.utc.to_s).to be >= now.utc.to_s
      expect(user.last_login_at.utc.to_s).to be <= (now.utc+2).to_s
    end

    it "logs logout time on logout" do
      login_user
      now = Time.now.in_time_zone
      logout_user

      expect(User.last.last_logout_at).not_to be_nil

      expect(User.last.last_logout_at.utc.to_s).to be >= now.utc.to_s
      expect(User.last.last_logout_at.utc.to_s).to be <= (now+2).utc.to_s
    end

    it "logs last activity time when logged in" do
      sorcery_controller_property_set(:register_last_activity_time, true)

      login_user
      now = Time.now.in_time_zone
      get :some_action

      last_activity_at = User.last.last_activity_at

      expect(last_activity_at).to be_present
      expect(last_activity_at.utc.to_s).to be >= now.utc.to_s
      expect(last_activity_at.utc.to_s).to be <= (now+2).utc.to_s
    end

    it "logs last IP address when logged in" do
      login_user
      get :some_action

      expect(User.last.last_login_from_ip_address).to eq "0.0.0.0"
    end

    it "updates nothing but activity fields" do
      original_user_name = User.last.username
      login_user
      get :some_action_making_a_non_persisted_change_to_the_user

      expect(User.last.username).to eq original_user_name
    end

    it "'current_users' holds the user object when 1 user is logged in" do
      login_user
      get :some_action

      expect(subject.current_users).to match([User.sorcery_adapter.find(user.id)])
    end

    it "'current_users' shows all current_users, whether they have logged out before or not." do
      user1 = create_new_user({:username => 'gizmo1', :email => "bla1@bla.com", :password => 'secret1'})
      login_user(user1)
      get :some_action
      clear_user_without_logout
      user2 = create_new_user({:username => 'gizmo2', :email => "bla2@bla.com", :password => 'secret2'})
      login_user(user2)
      get :some_action
      clear_user_without_logout
      user3 = create_new_user({:username => 'gizmo3', :email => "bla3@bla.com", :password => 'secret3'})
      login_user(user3)
      get :some_action

      expect(subject.current_users.size).to eq 3
      expect(subject.current_users[0]).to eq User.sorcery_adapter.find(user1.id)
      expect(subject.current_users[1]).to eq User.sorcery_adapter.find(user2.id)
      expect(subject.current_users[2]).to eq User.sorcery_adapter.find(user3.id)
    end

    it "does not register login time if configured so" do
      sorcery_controller_property_set(:register_login_time, false)
      now = Time.now.in_time_zone
      login_user

      expect(user.last_login_at).to be_nil
    end

    it "does not register logout time if configured so" do
      sorcery_controller_property_set(:register_logout_time, false)
      now = Time.now.in_time_zone
      login_user
      logout_user

      expect(user.last_logout_at).to be_nil
    end

    it "does not register last activity time if configured so" do
      sorcery_controller_property_set(:register_last_activity_time, false)
      now = Time.now.in_time_zone
      login_user
      get :some_action

      expect(user.last_activity_at).to be_nil
    end

    it "does not register last IP address if configured so" do
      sorcery_controller_property_set(:register_last_ip_address, false)
      ip_address = "127.0.0.1"
      login_user
      get :some_action

      expect(user.last_activity_at).to be_nil
    end

  end
end
