require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/../../shared_examples/user_reset_password_shared_examples')

describe "User with reset_password submodule" do

  it_behaves_like "rails_3_reset_password_model"
  
end