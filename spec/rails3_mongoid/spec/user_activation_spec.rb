require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/../app/mailers/sorcery_mailer')
require File.expand_path(File.dirname(__FILE__) + '/../../shared_examples/user_activation_shared_examples')

describe "User with activation submodule" do

  it_behaves_like "rails_3_activation_model"
  
end