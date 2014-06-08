require 'spec_helper'
require 'rails_app/app/mailers/sorcery_mailer'
require 'shared_examples/user_shared_examples'

describe User, "with no submodules (core)", :mongo_mapper => true do
  before(:all) do
    sorcery_reload!
  end

  describe User, "when app has plugin loaded" do
    it "User responds to .authenticates_with_sorcery!" do
      expect(User).to respond_to :authenticates_with_sorcery!
    end
  end

  # ----------------- PLUGIN CONFIGURATION -----------------------

  it_should_behave_like "rails_3_core_model"

  describe "external users" do

    it_should_behave_like "external_user"

  end

  context "when inherited" do
    it "inherits mongo_mapper keys" do
      User.class_eval do
        key :blabla
      end
      class SubUser < User
      end

      expect(SubUser.keys).to include("blabla")
    end
  end
end
