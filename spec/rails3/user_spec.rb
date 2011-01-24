require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "User with no submodules (core)" do
  before(:all) do
    plugin_model_configure
    ActiveRecord::Migrator.migrate("#{Rails.root}/db/migrate/core")
  end
  
  after(:all) do
    ActiveRecord::Migrator.rollback("#{Rails.root}/db/migrate/core")
  end

  describe User, "when app has plugin loaded" do
    it "should respond to the plugin activation class method" do
      ActiveRecord::Base.should respond_to(:activate_sorcery!)
      User.should respond_to(:activate_sorcery!)
    end
    
    it "plugin activation should yield config to block" do
      User.activate_sorcery! do |config|
        config.class.should == ::Sorcery::Model::Config 
      end
    end
  end

  # ----------------- PLUGIN CONFIGURATION -----------------------
  describe User, "loaded plugin configuration" do
    after(:each) do
      User.sorcery_config.reset!
    end
  
    it "should enable configuration option 'username_attribute_name'" do
      plugin_set_model_config_property(:username_attribute_name, :email)
      User.sorcery_config.username_attribute_name.should equal(:email)    
    end
  
    it "should enable configuration option 'password_attribute_name'" do
      plugin_set_model_config_property(:password_attribute_name, :mypassword)
      User.sorcery_config.password_attribute_name.should equal(:mypassword)
    end
    
    it "should enable configuration option 'email_attribute_name'" do
      plugin_set_model_config_property(:email_attribute_name, :my_email)
      User.sorcery_config.email_attribute_name.should equal(:my_email)
    end

    it "should enable two classes to have different configurations" do
      plugin_set_model_config_property(:username_attribute_name, :email)
      TestUser.sorcery_config.username_attribute_name.should equal(:username)
    end
  
  end

  # ----------------- PLUGIN ACTIVATED -----------------------
  describe User, "when activated with sorcery" do
    before(:all) do
      plugin_model_configure
    end
  
    before(:each) do
      User.delete_all
    end
  
    it "should respond to class method authenticate" do
      ActiveRecord::Base.should_not respond_to(:authenticate)
      User.should respond_to(:authenticate)
    end
  
    it "authenticate should return true if credentials are good" do
      create_new_user
      User.authenticate(@user.send(User.sorcery_config.username_attribute_name), 'secret').should be_true
    end
  
    it "authenticate should return false if credentials are bad" do
      create_new_user
      User.authenticate(@user.send(User.sorcery_config.username_attribute_name), 'wrong!').should be_false
    end
  
  end

end