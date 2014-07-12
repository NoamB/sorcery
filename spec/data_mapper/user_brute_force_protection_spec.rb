require 'spec_helper'

require 'shared_examples/user_brute_force_protection_shared_examples'

describe User, "with brute_force_protection submodule", :data_mapper => true do

  it_behaves_like "rails_3_brute_force_protection_model"

end
