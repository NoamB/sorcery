require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "User with activity logging submodule" do
  before(:all) do
  end
  
  after(:all) do
  end

  # ----------------- PLUGIN CONFIGURATION -----------------------
  describe User, "loaded plugin configuration" do
    before(:all) do
      plugin_model_configure([:activity_logging])
    end
  
    after(:each) do
      User.sorcery_config.reset!
    end
    
    it "should allow configuration option 'last_login_attribute_name'" do
      plugin_set_model_config_property(:last_login_attribute_name, :login_time)
      User.sorcery_config.last_login_attribute_name.should equal(:login_time)
    end
    
    it "should allow configuration option 'last_logout_attribute_name'" do
      plugin_set_model_config_property(:last_logout_attribute_name, :logout_time)
      User.sorcery_config.last_logout_attribute_name.should equal(:logout_time)
    end

  end

end
