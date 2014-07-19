require 'spec_helper'
require 'shared_examples/controller_activity_logging_shared_examples'

describe SorceryController, :data_mapper => true do

  # ----------------- ACTIVITY LOGGING -----------------------
  context "with activity logging features" do
    after(:each) do
      # NOTE dm-constraints supports only pg and mysql
      Authentication.all.destroy
      User.sorcery_adapter.delete_all
    end

    it_behaves_like "controller_activity_logging"

  end
end
