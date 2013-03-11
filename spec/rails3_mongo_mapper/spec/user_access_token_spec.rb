require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/../../shared_examples/user_access_token_shared_examples')

describe "User with access_token submodule" do

  it_behaves_like "rails_3_access_token_model"

end
