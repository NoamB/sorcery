shared_examples_for "oauth_controller" do
  describe "using 'create_from'" do
    before(:each) do
      stub_all_oauth_requests!
      User.delete_all
      Authentication.delete_all
    end

    it "creates a new user" do
      sorcery_model_property_set(:authentications_class, Authentication)
      sorcery_controller_external_property_set(:twitter, :user_info_mapping, {:username => "screen_name"})

      expect { get :test_create_from_provider, :provider => "twitter" }.to change { User.count }.by 1
      expect(User.first.username).to eq "nbenari"
    end

    it "supports nested attributes" do
      sorcery_model_property_set(:authentications_class, Authentication)
      sorcery_controller_external_property_set(:twitter, :user_info_mapping, {:username => "status/text"})

      expect { get :test_create_from_provider, :provider => "twitter" }.to change { User.count }.by 1
      expect(User.first.username).to eq "coming soon to sorcery gem: twitter and facebook authentication support."
    end

    it "does not crash on missing nested attributes" do
      sorcery_model_property_set(:authentications_class, Authentication)
      sorcery_controller_external_property_set(:twitter, :user_info_mapping, {:username => "status/text", :created_at => "does/not/exist"})

      expect { get :test_create_from_provider, :provider => "twitter" }.to change { User.count }.by 1
      expect(User.first.username).to eq "coming soon to sorcery gem: twitter and facebook authentication support."
      expect(User.first.created_at).not_to be_nil
    end

    it "binds new provider" do
      sorcery_model_property_set(:authentications_class, UserProvider)

      current_user = custom_create_new_external_user(:facebook, UserProvider)
      login_user(current_user)

      expect { get :test_add_second_provider, :provider => "twitter" }.to change { UserProvider.count }.by 1
      expect(UserProvider.where(:user_id => current_user.id).size).to eq 2
      expect(User.count).to eq 1
    end

    describe "with a block" do

      before(:each) do
        user = User.new(:username => 'nbenari')
        user.save!(:validate => false)
        user.authentications.create(:provider => 'github', :uid => '456')
      end

      it "does not create user" do
        sorcery_model_property_set(:authentications_class, Authentication)
        sorcery_controller_external_property_set(:twitter, :user_info_mapping, {:username => "screen_name"})

        expect { get :test_create_from_provider_with_block, :provider => "twitter" }.not_to change { User.count }
      end

    end
  end
end
