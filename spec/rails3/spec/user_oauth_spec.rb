require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/../../shared_examples/user_oauth_shared_examples')

describe "User with oauth submodule" do
  before(:all) do
    ActiveRecord::Migrator.migrate("#{Rails.root}/db/migrate/external")
  end
  
  after(:all) do
    ActiveRecord::Migrator.rollback("#{Rails.root}/db/migrate/external")
  end

  it_behaves_like "rails_3_oauth_model"
  
end