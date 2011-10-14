require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/../../shared_examples/user_brute_force_protection_shared_examples')

describe "User with brute_force_protection submodule" do

  it_behaves_like "rails_3_brute_force_protection_model"
  
end