require 'spec_helper'
require 'rails_app/app/mailers/sorcery_mailer'
require 'shared_examples/user_shared_examples'

describe User, "with no submodules (core)", :mongoid => true do
  before(:all) do
    sorcery_reload!
  end

  context "when app has plugin loaded" do
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
    it "inherits mongoid fields" do
      User.class_eval do
        field :blabla
      end
      class SubUser < User
      end

      expect(SubUser.fields).to include("blabla")
    end
  end

  describe "increment" do
    it "increments attribute" do
      User.class_eval do
        field :some_number, type: Integer
      end

      user = User.new(some_number: 3)
      user.sorcery_adapter.increment(:some_number)

      expect(user.some_number).to eql 4
    end
  end

end
