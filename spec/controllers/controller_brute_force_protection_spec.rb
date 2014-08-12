require 'spec_helper'

describe SorceryController do

  let(:user) { double('user', id: 42, email: 'bla@bla.com') }

  def request_test_login
    get :test_login, email: 'bla@bla.com', password: 'blabla'
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
      allow(User).to receive(:authenticate)
      allow(User.sorcery_adapter).to receive(:find_by_credentials).with(['bla@bla.com', 'blabla']).and_return(user)

      expect(user).to receive(:register_failed_login!).exactly(3).times

      3.times { request_test_login }
    end

    it "resets the counter on a good login" do
      # dirty hack for rails 4
      allow(@controller).to receive(:register_last_activity_time_to_db)

      allow(User).to receive(:authenticate).and_return(user)
      expect(user).to receive_message_chain(:sorcery_adapter, :update_attribute).with(:failed_logins_count, 0)

      get :test_login, email: 'bla@bla.com', password: 'secret'
    end
  end
end
