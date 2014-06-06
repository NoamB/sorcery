require 'spec_helper'
require 'shared_examples/user_remember_me_shared_examples'

describe User, "with remember_me submodule", :active_record => true do
  before(:all) do
    ActiveRecord::Migrator.migrate("#{Rails.root}/db/migrate/remember_me")
    User.reset_column_information
  end

  after(:all) do
    ActiveRecord::Migrator.rollback("#{Rails.root}/db/migrate/remember_me")
  end

  it_behaves_like "rails_3_remember_me_model"

end