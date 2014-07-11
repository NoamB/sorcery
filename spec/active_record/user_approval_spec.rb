require 'spec_helper'

require 'rails_app/app/mailers/sorcery_mailer'
require 'shared_examples/user_approval_shared_examples'

describe User, "with approval submodule", :active_record => true do
  before(:all) do
    ActiveRecord::Migrator.migrate("#{Rails.root}/db/migrate/approval")
    User.reset_column_information
  end

  after(:all) do
    ActiveRecord::Migrator.rollback("#{Rails.root}/db/migrate/approval")
  end

  it_behaves_like "rails_3_approval_model"

end
