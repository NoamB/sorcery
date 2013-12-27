require 'spec_helper'

require 'shared_examples/user_reset_password_shared_examples'

describe "User with reset_password submodule", :rails3 => true do

  it_behaves_like "rails_3_reset_password_model"

end
