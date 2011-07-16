shared_examples_for "oauth_controller" do
  describe "using 'create_from'" do
    before(:each) do
      stub_all_oauth_requests!
      User.delete_all
      Authentication.delete_all
    end
      
    it "should create a new user" do
      sorcery_model_property_set(:authentications_class, Authentication)
      sorcery_controller_external_property_set(:twitter, :user_info_mapping, {:username => "screen_name"})
      lambda do
        get :test_create_from_provider, :provider => "twitter"
      end.should change(User, :count).by(1)
      User.first.username.should == "nbenari"
    end
    
    it "should support nested attributes" do
      sorcery_model_property_set(:authentications_class, Authentication)
      sorcery_controller_external_property_set(:twitter, :user_info_mapping, {:username => "status/text"})
      lambda do
        get :test_create_from_provider, :provider => "twitter"
      end.should change(User, :count).by(1)
      User.first.username.should == "coming soon to sorcery gem: twitter and facebook authentication support."
    end
    
    it "should not crash on missing nested attributes" do
      sorcery_model_property_set(:authentications_class, Authentication)
      sorcery_controller_external_property_set(:twitter, :user_info_mapping, {:username => "status/text", :created_at => "does/not/exist"})
      lambda do
        get :test_create_from_provider, :provider => "twitter"
      end.should change(User, :count).by(1)
      User.first.username.should == "coming soon to sorcery gem: twitter and facebook authentication support."
      User.first.created_at.should_not be_nil
    end
  end
end