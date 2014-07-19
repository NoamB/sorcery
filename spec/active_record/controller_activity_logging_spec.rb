require 'spec_helper'

require 'shared_examples/controller_activity_logging_shared_examples'

describe SorceryController, :active_record => true do
  before(:all) do
    ActiveRecord::Migrator.migrate("#{Rails.root}/db/migrate/activity_logging")
    User.reset_column_information
  end

  after(:all) do
    ActiveRecord::Migrator.rollback("#{Rails.root}/db/migrate/activity_logging")

    sorcery_controller_property_set(:register_login_time, true)
    sorcery_controller_property_set(:register_logout_time, true)
    sorcery_controller_property_set(:register_last_activity_time, true)
    # sorcery_controller_property_set(:last_login_from_ip_address_name, true)
  end

  # ----------------- ACTIVITY LOGGING -----------------------
  context "with activity logging features" do
    after(:each) do
      User.sorcery_adapter.delete_all
    end

    it_behaves_like "controller_activity_logging"

  end
end
