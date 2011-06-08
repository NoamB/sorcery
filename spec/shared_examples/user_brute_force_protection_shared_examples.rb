shared_examples_for "rails_3_brute_force_protection_model" do
  # ----------------- PLUGIN CONFIGURATION -----------------------
  describe User, "loaded plugin configuration" do
  
    before(:all) do
      sorcery_reload!([:brute_force_protection])
      create_new_user
    end
  
    after(:each) do
      User.sorcery_config.reset!
    end
    
    specify { @user.should respond_to(:failed_logins_count) }
    specify { @user.should respond_to(:lock_expires_at) }
 
    it "should enable configuration option 'failed_logins_count_attribute_name'" do
      sorcery_model_property_set(:failed_logins_count_attribute_name, :my_count)
      User.sorcery_config.failed_logins_count_attribute_name.should equal(:my_count)    
    end
    
    it "should enable configuration option 'lock_expires_at_attribute_name'" do
      sorcery_model_property_set(:lock_expires_at_attribute_name, :expires)
      User.sorcery_config.lock_expires_at_attribute_name.should equal(:expires)    
    end
    
    it "should enable configuration option 'consecutive_login_retries_amount_allowed'" do
      sorcery_model_property_set(:consecutive_login_retries_amount_limit, 34)
      User.sorcery_config.consecutive_login_retries_amount_limit.should equal(34)    
    end
    
    it "should enable configuration option 'login_lock_time_period'" do
      sorcery_model_property_set(:login_lock_time_period, 2.hours)
      User.sorcery_config.login_lock_time_period.should == 2.hours    
    end
  end
end