require 'spec_helper'
require 'shared_examples/user_activity_logging_shared_examples'

describe User, "with activity logging submodule", :active_record => true do

  before(:all) do
    ActiveRecord::Migrator.migrate("#{Rails.root}/db/migrate/activity_logging")
    User.reset_column_information
  end

  after(:all) do
    ActiveRecord::Migrator.rollback("#{Rails.root}/db/migrate/activity_logging")
  end

  it_behaves_like "rails_3_activity_logging_model"

end
