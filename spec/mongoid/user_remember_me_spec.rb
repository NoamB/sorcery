require 'spec_helper'
require 'shared_examples/user_remember_me_shared_examples'

describe User, "with remember_me submodule", :mongoid => true do

  it_behaves_like "rails_3_remember_me_model"

end