shared_examples_for "oauth2_controller" do
  describe "using 'create_from'" do
    before(:each) do
      stub_all_oauth2_requests!
      User.delete_all
      Authentication.delete_all
    end

    it "should create a new user" do
      sorcery_model_property_set(:authentications_class, Authentication)
      sorcery_controller_external_property_set(:facebook, :user_info_mapping, {:username => "name"})
      lambda do
        get :test_create_from_provider, :provider => "facebook"
      end.should change(User, :count).by(1)
      User.first.username.should == "Noam Ben Ari"
    end

    it "should support nested attributes" do
      sorcery_model_property_set(:authentications_class, Authentication)
      sorcery_controller_external_property_set(:facebook, :user_info_mapping, {:username => "hometown/name"})
      lambda do
        get :test_create_from_provider, :provider => "facebook"
      end.should change(User, :count).by(1)
      User.first.username.should == "Haifa, Israel"
    end

    it "should not crash on missing nested attributes" do
      sorcery_model_property_set(:authentications_class, Authentication)
      sorcery_controller_external_property_set(:facebook, :user_info_mapping, {:username => "name", :created_at => "does/not/exist"})
      lambda do
        get :test_create_from_provider, :provider => "facebook"
      end.should change(User, :count).by(1)
      User.first.username.should == "Noam Ben Ari"
      User.first.created_at.should_not be_nil
    end
   
    describe "with a block" do
      
      before(:each) do
        user = User.new(:username => 'Noam Ben Ari')
        user.save!(:validate => false)
        user.authentications.create(:provider => 'twitter', :uid => '456')
      end
      
      it "should not create user" do
        sorcery_model_property_set(:authentications_class, Authentication)
        sorcery_controller_external_property_set(:facebook, :user_info_mapping, {:username => "name"})
        lambda do
          # test_create_from_provider_with_block in controller will check for uniqueness of username
          get :test_create_from_provider_with_block, :provider => "facebook"
        end.should_not change(User, :count)
      end
    
    end
  end
end