require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "User with activation submodule" do
  before(:all) do
    ActiveRecord::Migrator.migrate("#{Rails.root}/db/migrate/activation")
  end
  
  after(:all) do
    ActiveRecord::Migrator.rollback("#{Rails.root}/db/migrate/activation")
  end

  # ----------------- PLUGIN CONFIGURATION -----------------------
  describe User, "loaded plugin configuration" do
    before(:all) do
      plugin_model_configure([:user_activation])
    end
  
    after(:each) do
      User.simple_auth_config.reset!
    end
    
    it "should enable configuration option 'activation_state_attribute_name'" do
      plugin_set_model_config_property(:activation_state_attribute_name, :status)
      User.simple_auth_config.activation_state_attribute_name.should equal(:status)    
    end
    
    it "should enable configuration option 'activation_code_attribute_name'" do
      plugin_set_model_config_property(:activation_code_attribute_name, :code)
      User.simple_auth_config.activation_code_attribute_name.should equal(:code)    
    end
    
    it "should enable configuration option 'simple_auth_mailer'" do
      plugin_set_model_config_property(:simple_auth_mailer, TestMailer)
      User.simple_auth_config.simple_auth_mailer.should equal(TestMailer)    
    end
    
    it "should enable configuration option 'activation_needed_email_method_name'" do
      plugin_set_model_config_property(:activation_needed_email_method_name, :my_activation_email)
      User.simple_auth_config.activation_needed_email_method_name.should equal(:my_activation_email)
    end
    
    it "should enable configuration option 'activation_success_email_method_name'" do
      plugin_set_model_config_property(:activation_success_email_method_name, :my_activation_email)
      User.simple_auth_config.activation_success_email_method_name.should equal(:my_activation_email)
    end
  end

  # ----------------- ACTIVATION PROCESS -----------------------
  describe User, "activation process" do
    before(:all) do
      plugin_model_configure([:user_activation])
    end
  
    after(:each) do
      User.simple_auth_config.reset!
    end
    
    it "should generate an activation code on registration" do
      create_new_user
      @user.activation_code.should_not be_nil
    end
    
    it "should initialize user state to 'pending'" do
      create_new_user
      @user.activation_state.should == "pending"
    end
    
    it "should respond to 'activate!'" do
      create_new_user
      @user.should respond_to(:activate!)
    end
    
    it "should clear activation code and change state to 'active' on activation" do
      create_new_user
      @user.activate!
      @user.activation_code.should be_nil
      @user.activation_state.should == "active"
    end
    
    it "should send the user an activation email" do
      old_size = ActionMailer::Base.deliveries.size
      create_new_user
      ActionMailer::Base.deliveries.size.should == old_size + 1
    end
  end

end