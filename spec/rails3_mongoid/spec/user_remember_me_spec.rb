require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/../../shared_examples/user_remember_me_shared_examples')

describe "User with remember_me submodule" do

  it_behaves_like "rails_3_remember_me_model"

end