require 'spec_helper'
require 'shared_examples/user_activity_logging_shared_examples'

describe User, "with activity logging submodule", :mongoid => true do

  it_behaves_like "rails_3_activity_logging_model"

end
