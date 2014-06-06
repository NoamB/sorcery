require 'spec_helper'
require 'rails_app/app/mailers/sorcery_mailer'
require 'shared_examples/user_activation_shared_examples'

describe User, "with activation submodule", :mongo_mapper => true do

  it_behaves_like "rails_3_activation_model"

end
