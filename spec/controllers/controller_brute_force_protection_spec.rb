require 'spec_helper'

describe SorceryController do

  let(:db_user) { User.sorcery_adapter.find_by_email(user.email) }
  let!(:user) { create_new_user }

  def request_test_login
    get :test_login, email: 'bla@bla.com', password: 'blabla'
  end

  before(:all) do
    if SORCERY_ORM == :active_record
      ActiveRecord::Migrator.migrate("#{Rails.root}/db/migrate/brute_force_protection")
      User.reset_column_information
    end
  end

  after(:all) do
    if SORCERY_ORM == :active_record
      ActiveRecord::Migrator.rollback("#{Rails.root}/db/migrate/brute_force_protection")
    end
  end

  # ----------------- SESSION TIMEOUT -----------------------
  describe "brute force protection features" do

    before(:all) do
      sorcery_reload!([:brute_force_protection])
    end

    after(:each) do
      Sorcery::Controller::Config.reset!
      sorcery_controller_property_set(:user_class, User)
      Timecop.return
    end

    it "counts login retries" do
      3.times { request_test_login }
      expect(db_user.failed_logins_count).to eq 3
    end

    it "generates unlock token before mail is sent" do
      sorcery_model_property_set(:consecutive_login_retries_amount_limit, 2)
      sorcery_model_property_set(:login_lock_time_period, 0)
      sorcery_model_property_set(:unlock_token_mailer, SorceryMailer)
      3.times { request_test_login }
      expect(ActionMailer::Base.deliveries.last.body.to_s.match(db_user.unlock_token)).not_to be_nil
    end

    it "unlocks after entering unlock token" do
      sorcery_model_property_set(:consecutive_login_retries_amount_limit, 2)
      sorcery_model_property_set(:login_lock_time_period, 0)
      sorcery_model_property_set(:unlock_token_mailer, SorceryMailer)
      3.times { request_test_login }

      expect(db_user.unlock_token).not_to be_nil

      token = db_user.unlock_token
      user = User.load_from_unlock_token(token)

      expect(user).not_to be_nil

      user.unlock!
      expect(User.load_from_unlock_token(db_user.unlock_token)).to be_nil
    end

    it "resets the counter on a good login" do
      # dirty hack for rails 4
      allow(@controller).to receive(:register_last_activity_time_to_db)

      sorcery_model_property_set(:consecutive_login_retries_amount_limit, 5)
      3.times { request_test_login }
      get :test_login, email: 'bla@bla.com', password: 'secret'

      expect(db_user.failed_logins_count).to eq 0
    end

    it "locks user when number of retries reached the limit" do
      expect(db_user.lock_expires_at).to be_nil

      sorcery_model_property_set(:consecutive_login_retries_amount_limit, 1)
      request_test_login

      expect(db_user.reload.lock_expires_at).not_to be_nil
    end

    it "unlocks after lock time period passes" do
      sorcery_model_property_set(:consecutive_login_retries_amount_limit, 2)
      sorcery_model_property_set(:login_lock_time_period, 0.2)
      2.times { request_test_login }

      expect(db_user.reload.lock_expires_at).not_to be_nil

      Timecop.travel(Time.now.in_time_zone + 0.3)
      request_test_login

      expect(db_user.reload.lock_expires_at).to be_nil
    end

    it "doest not unlock if time period is 0 (permanent lock)" do
      sorcery_model_property_set(:consecutive_login_retries_amount_limit, 2)
      sorcery_model_property_set(:login_lock_time_period, 0)
      2.times { request_test_login }
      unlock_date = db_user.lock_expires_at
      Timecop.travel(Time.now.in_time_zone + 1)
      request_test_login

      expect(db_user.lock_expires_at.to_s).to eq unlock_date.to_s
    end

    context "unlock_token_mailer_disabled is true" do

      before(:each) do
        sorcery_model_property_set(:unlock_token_mailer_disabled, true)
        sorcery_model_property_set(:consecutive_login_retries_amount_limit, 2)
        sorcery_model_property_set(:login_lock_time_period, 0)
        sorcery_model_property_set(:unlock_token_mailer, SorceryMailer)
      end

      it "generates unlock token after user locked" do
        3.times { request_test_login }

        expect(db_user.unlock_token).to be_present
      end

      it "doest *not* automatically send unlock mail" do
        3.times { request_test_login }

        expect(ActionMailer::Base.deliveries.size).to eq 0
      end

    end

    context "unlock_token_mailer_disabled is false" do

      before(:each) do
        sorcery_model_property_set(:unlock_token_mailer_disabled, false)
        sorcery_model_property_set(:consecutive_login_retries_amount_limit, 3)
        sorcery_model_property_set(:login_lock_time_period, 0)
        sorcery_model_property_set(:unlock_token_mailer, SorceryMailer)
      end

      it "sets the unlock token after user locked" do
        3.times { request_test_login }

        expect(db_user.unlock_token).to be_present
      end

      it "automatically sends unlock mail" do
        expect(ActionMailer::Base.deliveries.size).to eq 1
      end

    end

  end
end
