require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

# ----------------- PASSWORD CONFIRMATION -----------------------
describe User, "field confirmation" do
  before(:all) do
    plugin_model_configure([:field_confirmation])
    ActiveRecord::Migrator.migrate("#{Rails.root}/db/migrate/core")
  end
  
  after(:all) do
    ActiveRecord::Migrator.rollback("#{Rails.root}/db/migrate/core")
  end
  
  before(:each) do
    User.delete_all
  end

  after(:each) do
    User.sorcery_config.reset!
  end

  it "should enable configuration option 'password_confirmation_attribute_name'" do
    plugin_set_model_config_property(:password_confirmation_attribute_name, :mypassword_conf)
    User.sorcery_config.password_confirmation_attribute_name.should equal(:mypassword_conf)
  end
  
  it "should not register a user with mismatching password fields" do
    @user = User.new(:username => 'gizmo', :email => "bla@bla.com", :password => 'secret', :password_confirmation => 'secrer')
    @user.valid?.should == false
    @user.save.should == false
    expect{@user.save!}.to raise_error(ActiveRecord::RecordInvalid)
  end
end