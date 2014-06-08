require 'spec_helper'
require 'shared_examples/user_oauth_shared_examples'

describe User, "with oauth submodule", :mongoid => true do

  it_behaves_like "rails_3_oauth_model"

end