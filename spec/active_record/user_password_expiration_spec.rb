require 'spec_helper'
require 'shared_examples/user_password_expiration_shared_examples'

describe 'User with password_expiration submodule' do
  before(:all) do
    ActiveRecord::Migrator.migrate("#{Rails.root}/db/migrate/password_expiration")
    User.reset_column_information
  end

  after(:all) do
    ActiveRecord::Migrator.rollback("#{Rails.root}/db/migrate/password_expiration")
  end

  it_behaves_like 'rails_3_password_expiration_model'

end
