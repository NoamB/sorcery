require 'spec_helper'

require 'rails_app/app/mailers/sorcery_mailer'
require 'shared_examples/user_approval_shared_examples'

describe User, "with approval submodule", :datamapper => true do

  it_behaves_like "rails_3_approval_model"

end
