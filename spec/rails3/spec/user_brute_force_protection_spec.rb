require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/../../shared_examples/user_brute_force_protection_shared_examples')

describe "User with brute_force_protection submodule" do
  before(:all) do
    ActiveRecord::Migrator.migrate("#{Rails.root}/db/migrate/brute_force_protection")
  end
  
  after(:all) do
    ActiveRecord::Migrator.rollback("#{Rails.root}/db/migrate/brute_force_protection")
  end

  it_behaves_like "rails_3_brute_force_protection_model"
  
end