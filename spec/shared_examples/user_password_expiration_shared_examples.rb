shared_examples_for 'rails_3_password_expiration_model' do
  # ----------------- PLUGIN CONFIGURATION -----------------------
  describe User, 'loaded plugin configuration' do

    before(:all) do
      sorcery_reload!([:password_expiration])
      create_new_user
    end

    after(:each) do
      User.sorcery_config.reset!
    end

    specify { expect(@user).to respond_to(:password_changed_at) }

    it "should enable configuration option 'password_changed_at_attribute_name'" do
      sorcery_model_property_set(:password_changed_at_attribute_name, :expires)
      expect(User.sorcery_config.password_changed_at_attribute_name).to eq :expires
    end

    it "should enable configuration option 'password_expiration_time_period'" do
      time_period = 6.months
      sorcery_model_property_set(:password_expiration_time_period, time_period)
      expect(User.sorcery_config.password_expiration_time_period).to eq time_period
    end
  end

  # ----------------- PLUGIN ACTIVATED -----------------------
  describe User, 'when activated with sorcery' do

    before(:all) do
      sorcery_reload!([:password_expiration])
    end

    before(:each) do
      User.delete_all
      create_new_user
    end

    after(:each) do
      Timecop.return
    end

    it 'sets password_changed_at field when user created' do
      expect(@user.password_changed_at).to_not be_nil
    end

    it 'updates password_changed_at field when password changed' do
      start_password_changed_at = @user.password_changed_at

      Timecop.travel(Time.now + 1.minute)
      @user.password = 'updated_password'
      @user.save

      expect(@user.password_changed_at).to_not eq start_password_changed_at
    end

    it 'updates password_changed_at field when crypted password changed' do
      start_password_changed_at = @user.password_changed_at

      Timecop.travel(Time.now + 1.minute)
      @user.crypted_password = 'crypted_password'
      @user.save

      expect(@user.password_changed_at).to_not eq start_password_changed_at
    end

    it 'allows manual setting of password_changed_at field' do
      start_password_changed_at = @user.password_changed_at
      modified_password_changed_at = start_password_changed_at + 1.day.to_i

      Timecop.travel(Time.now + 1.month)
      @user.password = 'updated_password'
      @user.password_changed_at = modified_password_changed_at
      @user.save

      expect(@user.password_changed_at).to eq modified_password_changed_at
    end

    it "knows if a user's password needs to be changed" do
      expiration_time_period = User.sorcery_config.password_expiration_time_period
      expiration = @user.password_changed_at.to_time + expiration_time_period.seconds
      before_expiration = expiration - 1.second
      after_expiration = expiration + 1.second

      Timecop.travel(before_expiration)

      expect(@user.password_expired?).to be_false

      Timecop.travel(after_expiration)

      expect(@user.password_expired?).to be_true
    end

    it 'can force a user to need password changed' do
      expect(@user.password_expired?).to be_false

      @user.expire_password!

      expect(@user.password_expired?).to be_true
    end

    it "updates a user's password" do
      original_password = @user.crypted_password
      change_password_hash =  {
                                :current_password => 'secret',
                                :password => 'new_secret',
                                :password_confirmation => 'new_secret'
                              }

      @user.update_password!(change_password_hash)

      expect(@user.crypted_password).to_not eq original_password
    end
  end
end
