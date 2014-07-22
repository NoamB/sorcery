require 'spec_helper'
require 'shared_examples/user_password_validation_shared_examples'

describe User, "with password_validation submodule", :mongoid => true do

  it_behaves_like "rails_3_password_validation_model"

end
