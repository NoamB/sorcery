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

    it "binds new provider" do
      sorcery_model_property_set(:authentications_class, UserProvider)

      current_user = custom_create_new_external_user(:facebook, UserProvider)
      login_user(current_user)

      lambda do
        get :test_add_second_provider, :provider => "twitter"
      end.should change(UserProvider, :count).by(1)

      UserProvider.where(:user_id => current_user.id).should have(2).items
      User.should have(1).item
    end

    describe "with a block" do

      before(:each) do
        user = User.new(:username => 'nbenari')
        user.save!(:validate => false)
        user.authentications.create(:provider => 'github', :uid => '456')
      end

      it "should not create user" do
        sorcery_model_property_set(:authentications_class, Authentication)
        sorcery_controller_external_property_set(:twitter, :user_info_mapping, {:username => "screen_name"})
        lambda do
          get :test_create_from_provider_with_block, :provider => "twitter"
        end.should_not change(User, :count)
      end

    end
  end
end
