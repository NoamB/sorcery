require 'spec_helper'
require 'shared_examples/controller_activity_logging_shared_examples'

describe SorceryController, :mongoid => true do

  # ----------------- ACTIVITY LOGGING -----------------------
  context "with activity logging features" do
    after(:each) do
      User.sorcery_adapter.delete_all
    end


    it_behaves_like "controller_activity_logging"

  end
end
