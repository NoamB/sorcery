shared_examples_for "rails_3_access_token_model" do

  #
  # Plugin Configuration
  #

  describe User, "loaded plugin configuration" do
    before(:all) do
      sorcery_reload!([:access_token])
      create_new_user
    end

    after(:each) do
      User.sorcery_config.reset!
    end

    it "should allow configuration option 'access_token_mode'" do
      sorcery_model_property_set(:access_token_mode, 'session')
      User.sorcery_config.access_token_mode.should == 'session'
    end

    it "should allow configuration option 'access_token_duration'" do
      sorcery_model_property_set(:access_token_duration, 7.days.to_i)
      User.sorcery_config.access_token_duration.should == 7.days.to_i
    end

    it "should allow configuration option 'access_token_duration_from_last_activity'" do
      sorcery_model_property_set(:access_token_duration_from_last_activity, true)
      User.sorcery_config.access_token_duration_from_last_activity.should be_true
    end

    it "should allow configuration option 'access_token_max_per_user'" do
      sorcery_model_property_set(:access_token_max_per_user, 5)
      User.sorcery_config.access_token_max_per_user.should == 5
    end

  end

  #
  # Token creation and deletion
  #

  describe User, "token creation and deletion" do

    context "with 'access_token_mode' set to 'session'" do
      before(:all) do
        sorcery_reload!([:access_token])
      end

      before(:each) do
        sorcery_model_property_set(:access_token_mode, 'session')
        sorcery_model_property_set(:access_token_max_per_user, 5)
        User.delete_all
        AccessToken.delete_all
        create_new_user
      end

      after(:each) do
        User.sorcery_config.reset!
      end

      it "should create a token on each 'create_access_token'" do
        @user.create_access_token!
        @user.reload # <-- common support (mongomapper, mongoid, ..)
        @user.access_tokens.count.should == 1
      end

      it "should set access_token 'last_activity_at' on 'create_access_token'" do
        access_token = @user.create_access_token!
        access_token.last_activity_at.should_not be_nil
      end

      it "should not create more tokens than defined in 'max_per_user' attribute" do
        10.times do |i|
          ret = @user.create_access_token!
          if i >= 5
            ret.should be_nil
          end
        end
        @user.reload
        @user.access_tokens.count.should == 5
      end

      it "should delete invalid tokens and create new when max has been reached" do
        sorcery_model_property_set(:access_token_duration, 120) # seconds
        5.times { @user.create_access_token! }
        initial_count = @user.access_tokens.count
        expired       = []
        @user.access_tokens.each_with_index do |token, i|
          if i % 2 == 0
            token.created_at = Time.zone.now - 1.year
            token.save!
            expired << token.id
          end
        end
        @user.create_access_token!
        # expired tokens should no longer exist
        expired.any? {|token_id| AccessToken.find_by_id(token_id) }.should be_false
        @user.access_tokens.count.should == (initial_count - expired.count + 1)
      end

    end

    context "with 'access_token_mode' set to 'single_token'" do
      before(:all) do
        sorcery_reload!([:access_token])
      end

      before(:each) do
        sorcery_model_property_set(:access_token_mode, 'single_token')
        User.delete_all
        AccessToken.delete_all
        create_new_user
      end

      after(:each) do
        User.sorcery_config.reset!
      end

      it "should create the access_token on user creation" do
        @user.access_tokens.count.should == 1
      end

      it "should set last_activity_at of user access token" do
        @user.access_tokens.first.last_activity_at.should_not be_nil
      end 

      it "should return nil on 'create_access_token' when stored token is valid" do
        @user.create_access_token!.should be_nil
      end

      it "should destroy invalid tokens and create new on 'create_access_token'" do
        sorcery_model_property_set(:access_token_duration, 120)
        # expire current token
        token = @user.access_tokens.first
        token.created_at = Time.zone.now - 1.year
        token.expired?.should be_true
        token.valid?(:auth).should be_false
        token.save!
        expired_token_id = token.id
        # create new token, expect deletion of expired token
        new_token = @user.create_access_token!
        expired_token_id.should_not == new_token.id
        AccessToken.find_by_id(expired_token_id).should be_nil
      end

    end

  end

  #
  # Token authentication
  #

  describe AccessToken, "token authentication" do
    before(:all) do
      sorcery_reload!([:access_token])
    end

    before(:each) do
      AccessToken.delete_all
    end

    after(:each) do
      User.sorcery_config.reset!
    end

    it "should be valid if duration is unset" do
      sorcery_model_property_set(:access_token_duration, nil)
      create_new_access_token
      @api_access_token.created_at = Time.zone.now - 1.year
      @api_access_token.save!
      @api_access_token.valid?(:auth).should be_true
    end

    it "should be invalid if it has expired when evaluated against creation time" do
      sorcery_model_property_set(:access_token_duration, 120)
      sorcery_model_property_set(:access_token_duration_from_last_activity, false)
      create_new_access_token
      @api_access_token.created_at = Time.zone.now - 1.year
      @api_access_token.save!
      @api_access_token.expired?.should be_true
      @api_access_token.valid?(:auth).should be_false
    end

    it "should be valid if it has not expired when evaluated against creation time" do
      sorcery_model_property_set(:access_token_duration, 120)
      sorcery_model_property_set(:access_token_duration_from_last_activity, false)
      create_new_access_token
      @api_access_token.expired?.should be_false
      @api_access_token.valid?(:auth).should be_true
    end

    it "should be invalid if it has expired when evaluated against last activity time" do
      sorcery_model_property_set(:access_token_duration, 120)
      sorcery_model_property_set(:access_token_duration_from_last_activity, true)
      create_new_access_token
      @api_access_token.last_activity_at = Time.zone.now - 3.minutes
      @api_access_token.save!
      @api_access_token.expired?.should be_true
      @api_access_token.valid?(:auth).should be_false
    end

     it "should be valid if it has not expired when evaluated against last activity time" do
      sorcery_model_property_set(:access_token_duration, 120)
      sorcery_model_property_set(:access_token_duration_from_last_activity, true)
      create_new_access_token
      @api_access_token.last_activity_at = Time.zone.now - 1.minutes
      @api_access_token.save!
      @api_access_token.expired?.should be_false
      @api_access_token.valid?(:auth).should be_true
    end

  end

end
