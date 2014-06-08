require 'spec_helper'
require 'shared_examples/user_oauth_shared_examples'

describe User, "with oauth submodule", :active_record => true do
  before(:all) do
    ActiveRecord::Migrator.migrate("#{Rails.root}/db/migrate/external")
    User.reset_column_information
  end

  after(:all) do
    ActiveRecord::Migrator.rollback("#{Rails.root}/db/migrate/external")
  end

  it_behaves_like "rails_3_oauth_model"

end