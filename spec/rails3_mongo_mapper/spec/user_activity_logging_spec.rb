require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/../../shared_examples/user_activity_logging_shared_examples')

describe "User with activity logging submodule" do

  it_behaves_like "rails_3_activity_logging_model"

end
