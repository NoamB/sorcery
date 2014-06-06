require 'spec_helper'
require 'rails_app/app/mailers/sorcery_mailer'
require 'shared_examples/user_shared_examples'

describe User, "with no submodules (core)", :active_record => true do
  before(:all) do
    sorcery_reload!
  end

  context "when app has plugin loaded" do
    it "responds to the plugin activation class method" do
      expect(ActiveRecord::Base).to respond_to :authenticates_with_sorcery!
    end

    it "User responds to .authenticates_with_sorcery!" do
      expect(User).to respond_to :authenticates_with_sorcery!
    end
  end

  # ----------------- PLUGIN CONFIGURATION -----------------------

  it_should_behave_like "rails_3_core_model"

  describe "external users" do
    before(:all) do
      ActiveRecord::Migrator.migrate("#{Rails.root}/db/migrate/external")
      User.reset_column_information
      sorcery_reload!
    end

    after(:all) do
      ActiveRecord::Migrator.rollback("#{Rails.root}/db/migrate/external")
    end

    it_should_behave_like "external_user"
  end
end
