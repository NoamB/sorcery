require 'spec_helper'

require 'shared_examples/user_password_expiration_shared_examples'

describe 'User with password_expiration submodule', :rails3 => true do

  it_behaves_like 'rails_3_password_expiration_model'

end
