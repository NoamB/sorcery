require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/../../shared_examples/user_oauth_shared_examples')

describe "User with oauth submodule" do

  it_behaves_like "rails_3_oauth_model"
  
end