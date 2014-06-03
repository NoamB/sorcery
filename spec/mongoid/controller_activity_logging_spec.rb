require 'spec_helper'

require 'shared_examples/controller_activity_logging_shared_examples'

describe SorceryController, :mongoid => true do

  # ----------------- ACTIVITY LOGGING -----------------------
  describe SorceryController, "with activity logging features" do
    before(:all) do
      sorcery_reload!([:activity_logging])
    end

    before(:each) do
      create_new_user
    end

    after(:each) do
      User.delete_all
    end

    it_behaves_like "controller_activity_logging"

  end
end
