shared_examples_for "rails_3_brute_force_protection_model" do
  # ----------------- PLUGIN CONFIGURATION -----------------------
  describe User, "loaded plugin configuration" do

    let(:config) { User.sorcery_config }
  
    before(:all) do
      sorcery_reload!([:brute_force_protection])
      create_new_user
    end
  
    after(:each) do
      User.sorcery_config.reset!
    end
    
    specify { expect(@user).to respond_to(:failed_logins_count) }
    specify { expect(@user).to respond_to(:lock_expires_at) }
 
    it "enables configuration option 'failed_logins_count_attribute_name'" do
      sorcery_model_property_set(:failed_logins_count_attribute_name, :my_count)
      expect(config.failed_logins_count_attribute_name).to eq :my_count
    end
    
    it "enables configuration option 'lock_expires_at_attribute_name'" do
      sorcery_model_property_set(:lock_expires_at_attribute_name, :expires)
      expect(config.lock_expires_at_attribute_name).to eq :expires
    end
    
    it "enables configuration option 'consecutive_login_retries_amount_allowed'" do
      sorcery_model_property_set(:consecutive_login_retries_amount_limit, 34)
      expect(config.consecutive_login_retries_amount_limit).to eq 34
    end
    
    it "enables configuration option 'login_lock_time_period'" do
      sorcery_model_property_set(:login_lock_time_period, 2.hours)
      expect(config.login_lock_time_period).to eq 2.hours
    end
  end
end