shared_examples_for 'oauth2_controller' do
  describe 'using create_from' do
    before(:each) do
      stub_all_oauth2_requests!
      User.sorcery_adapter.delete_all
      Authentication.sorcery_adapter.delete_all
    end

    it 'creates a new user from facebook' do
      sorcery_model_property_set(:authentications_class, Authentication)
      sorcery_controller_external_property_set(:facebook, :user_info_mapping, { username: 'name' })

      expect { get :test_create_from_provider, provider: 'facebook' }.to change { User.count }.by 1
      expect(User.first.username).to eq 'Noam Ben Ari'
    end

    it 'creates a new user from vkontakte with email scope' do
      sorcery_model_property_set(:authentications_class, Authentication)
      sorcery_controller_external_property_set(:vk, :user_info_mapping, {:email => "email", :username => "full_name"})

      expect { get :test_create_from_provider, provider: 'vk' }.to change { User.count }.by 1
      expect(User.first.username).to eq 'Noam Ben Ari'
      expect(User.first.email).to eq 'nbenari@gmail.com'
    end

    it 'creates a new user from vkontakte without email scope' do
      sorcery_model_property_set(:authentications_class, Authentication)
      sorcery_controller_external_property_set(:vk, :user_info_mapping, {:username => "full_name"})
      sorcery_controller_external_property_set(:vk, :scope, "")

      expect { get :test_create_from_provider, provider: 'vk' }.to change { User.count }.by 1
      expect(User.first.username).to eq 'Noam Ben Ari'
      expect(User.first.email).to be_nil
    end

    it 'supports nested attributes' do
      sorcery_model_property_set(:authentications_class, Authentication)
      sorcery_controller_external_property_set(:facebook, :user_info_mapping, { username: 'hometown/name' })

      expect { get :test_create_from_provider, provider: 'facebook' }.to change { User.count }.by(1)
      expect(User.first.username).to eq 'Haifa, Israel'
    end

    it 'does not crash on missing nested attributes' do
      sorcery_model_property_set(:authentications_class, Authentication)
      sorcery_controller_external_property_set(:facebook, :user_info_mapping, { username: 'name', created_at: 'does/not/exist' })

      expect { get :test_create_from_provider, provider: 'facebook' }.to change { User.count }.by 1
      expect(User.first.username).to eq 'Noam Ben Ari'
      expect(User.first.created_at).not_to be_nil
    end

    describe 'with a block' do

      before(:each) do
        user = User.new(username: 'Noam Ben Ari')
        user.save!(validate: false)
        user.authentications.create(provider: 'twitter', uid: '456')
      end

      it 'does not create user' do
        sorcery_model_property_set(:authentications_class, Authentication)
        sorcery_controller_external_property_set(:facebook, :user_info_mapping, { username: 'name' })

        # test_create_from_provider_with_block in controller will check for uniqueness of username
        expect { get :test_create_from_provider_with_block, provider: 'facebook' }.not_to change { User.count }
      end

    end
  end
end
