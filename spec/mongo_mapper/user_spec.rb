require 'spec_helper'

require 'rails_app/app/mailers/sorcery_mailer'
require 'shared_examples/user_shared_examples'

describe "User with no submodules (core)" do
  before(:all) do
    sorcery_reload!
  end

  describe User, "when app has plugin loaded" do
    it "User should respond_to .authenticates_with_sorcery!" do
      User.should respond_to(:authenticates_with_sorcery!)
    end
  end

  # ----------------- PLUGIN CONFIGURATION -----------------------

  it_should_behave_like "rails_3_core_model"

  describe User, "external users" do

    it_should_behave_like "external_user"

  end

  describe User, "when inherited" do
    it "should inherit mongo_mapper keys" do
      User.class_eval do
        key :blabla
      end
      class SubUser < User
      end

      SubUser.keys.should include("blabla")
    end
  end
end
