shared_examples_for "rails_3_remember_me_model" do
  # ----------------- PLUGIN CONFIGURATION -----------------------
  describe User, "loaded plugin configuration" do
    before(:all) do
      sorcery_reload!([:remember_me])
      create_new_user
    end
  
    after(:each) do
      User.sorcery_config.reset!
    end
    
    it "should allow configuration option 'remember_me_token_attribute_name'" do
      sorcery_model_property_set(:remember_me_token_attribute_name, :my_token)
      User.sorcery_config.remember_me_token_attribute_name.should equal(:my_token)
    end

    it "should allow configuration option 'remember_me_token_expires_at_attribute_name'" do
      sorcery_model_property_set(:remember_me_token_expires_at_attribute_name, :my_expires)
      User.sorcery_config.remember_me_token_expires_at_attribute_name.should equal(:my_expires)
    end
    
    specify { @user.should respond_to(:remember_me!) }
    
    specify { @user.should respond_to(:forget_me!) }
    
    it "should generate a new token on 'remember_me!'" do
      @user.remember_me_token.should be_nil
      @user.remember_me!
      @user.remember_me_token.should_not be_nil
    end
    
    # FIXME: assert on line 37 sometimes fails by a second
    it "should set an expiration based on 'remember_me_for' attribute" do
      sorcery_model_property_set(:remember_me_for, 2 * 60 * 60 * 24)
      @user.remember_me!
      @user.remember_me_token_expires_at.utc.to_s.should == (Time.now.in_time_zone + 2 * 60 * 60 * 24).utc.to_s
    end
    
    it "should delete the token and expiration on 'forget_me!'" do
      @user.remember_me!
      @user.remember_me_token.should_not be_nil
      @user.forget_me!
      @user.remember_me_token.should be_nil
      @user.remember_me_token_expires_at.should be_nil
    end
  end
end