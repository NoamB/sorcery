shared_examples_for "rails_3_activity_logging_model" do
  context "loaded plugin configuration" do
    before(:all) do
      sorcery_reload!([:activity_logging])
    end

    after(:each) do
      User.sorcery_config.reset!
    end

    it "allows configuration option 'last_login_at_attribute_name'" do
      sorcery_model_property_set(:last_login_at_attribute_name, :login_time)

      expect(User.sorcery_config.last_login_at_attribute_name).to eq :login_time
    end

    it "allows configuration option 'last_logout_at_attribute_name'" do
      sorcery_model_property_set(:last_logout_at_attribute_name, :logout_time)
      expect(User.sorcery_config.last_logout_at_attribute_name).to eq :logout_time
    end

    it "allows configuration option 'last_activity_at_attribute_name'" do
      sorcery_model_property_set(:last_activity_at_attribute_name, :activity_time)
      expect(User.sorcery_config.last_activity_at_attribute_name).to eq :activity_time
    end

    it "allows configuration option 'last_login_from_ip_adress'" do
      sorcery_model_property_set(:last_login_from_ip_address_name, :ip_address)
      expect(User.sorcery_config.last_login_from_ip_address_name).to eq :ip_address
    end

    describe ".current_users" do
      let(:user) { create_new_user }

      it "is empty when no users are logged in" do
        skip('unavailable in MongoMapper') if SORCERY_ORM == :mongo_mapper
        expect(User.current_users).to be_empty
      end

      it "holds the user object when 1 user is logged in" do
        skip('unavailable in MongoMapper') if SORCERY_ORM == :mongo_mapper
        user.set_last_activity_at(Time.now.in_time_zone)

        expect(User.current_users).to match([User.sorcery_adapter.find(user.id)])
      end

      it "'current_users' shows all current_users, whether they have logged out before or not." do
        skip('unavailable in MongoMapper') if SORCERY_ORM == :mongo_mapper
        User.sorcery_adapter.delete_all
        user1 = create_new_user({:username => 'gizmo1', :email => "bla1@bla.com", :password => 'secret1'})
        user2 = create_new_user({:username => 'gizmo2', :email => "bla2@bla.com", :password => 'secret2'})
        user3 = create_new_user({:username => 'gizmo3', :email => "bla3@bla.com", :password => 'secret3'})

        now = Time.now.in_time_zone
        [user1, user2, user3].each do |user|
          user.set_last_login_at(now)
          user.set_last_activity_at(now)
        end

        expect(User.current_users.map(&:id)).to match_array([user1, user2, user3].map(&:id))
        Timecop.travel now + 5
        user1.set_last_logout_at(Time.now.in_time_zone)
        expect(User.current_users.map(&:id)).to match_array([user2, user3].map(&:id))
        Timecop.return
      end

    end

    it '.set_last_login_at update last_login_at' do
      user = create_new_user
      now = Time.now.in_time_zone
      expect(user.sorcery_adapter).to receive(:update_attribute).with(:last_login_at, now)

      user.set_last_login_at(now)
    end

    it '.set_last_logout_at update last_logout_at' do
      user = create_new_user
      now = Time.now.in_time_zone
      expect(user.sorcery_adapter).to receive(:update_attribute).with(:last_logout_at, now)

      user.set_last_logout_at(now)
    end

    it '.set_last_activity_at update last_activity_at' do
      user = create_new_user
      now = Time.now.in_time_zone
      expect(user.sorcery_adapter).to receive(:update_attribute).with(:last_activity_at, now)

      user.set_last_activity_at(now)
    end

    it '.set_last_ip_addess update last_login_from_ip_address' do
      user = create_new_user
      expect(user.sorcery_adapter).to receive(:update_attribute).with(:last_login_from_ip_address, '0.0.0.0')

      user.set_last_ip_addess('0.0.0.0')
    end
  end
end
