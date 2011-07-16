shared_examples_for "rails_3_oauth_model" do
  # ----------------- PLUGIN CONFIGURATION -----------------------
  describe User, "loaded plugin configuration" do
  
    before(:all) do
      User.delete_all
      Authentication.delete_all
      sorcery_reload!([:external])
      sorcery_controller_property_set(:external_providers, [:twitter])
      sorcery_model_property_set(:authentications_class, Authentication)
      sorcery_controller_external_property_set(:twitter, :key, "eYVNBjBDi33aa9GkA3w")
      sorcery_controller_external_property_set(:twitter, :secret, "XpbeSdCoaKSmQGSeokz5qcUATClRW5u08QWNfv71N8")
      sorcery_controller_external_property_set(:twitter, :callback_url, "http://blabla.com")
      create_new_external_user(:twitter)
    end

    it "should respond to 'load_from_provider'" do
      User.should respond_to(:load_from_provider)
    end
    
    it "'load_from_provider' should load user if exists" do
      User.load_from_provider(:twitter,123).should == @user
    end
    
    it "'load_from_provider' should return nil if user doesn't exist" do
      User.load_from_provider(:twitter,980342).should be_nil
    end
    
  end
  
end