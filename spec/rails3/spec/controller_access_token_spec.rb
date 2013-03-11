require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe ApplicationController do

  #
  # Access Token
  #

  describe ApplicationController, "with access token features" do

    before(:all) do
      ActiveRecord::Migrator.migrate("#{Rails.root}/db/migrate/access_token")
      sorcery_reload!([:access_token])
      sorcery_controller_property_set(:restful_json_api, true)
      sorcery_model_property_set(:access_token_mode, 'session')
      sorcery_model_property_set(:access_token_max_per_user, 3)
      sorcery_model_property_set(:access_token_duration, 120)
    end

    before(:each) do
      create_new_user
    end

    after(:all) do
      ActiveRecord::Migrator.rollback("#{Rails.root}/db/migrate/access_token")
    end

    after(:each) do
      User.delete_all
      AccessToken.delete_all
    end


    # Login

    it "should create and return access token on successful login" do
      post(:test_login_access_token, :username => 'gizmo', :password => 'secret',
           :format => :json)

      assigns[:current_user].should == @user
      assigns[:api_access_token].should_not be_nil
      assigns[:api_access_token].token.should == @user.access_tokens(true).first.token

      response.code.should == '200'
      response.header['Content-Type'].should include('application/json')
      parsed_body = JSON.parse(response.body)
      parsed_body.key?('access_token').should be_true
      parsed_body['access_token'].length.should be > 0
    end

    it "should return stored access token on successful login when max allowed tokens has been reached" do
      3.times { @user.create_access_token! }
      tokens = @user.access_tokens(true).map(&:id)
      post(:test_login_access_token, :username => 'gizmo', :password => 'secret',
           :format => :json)

      assigns[:current_user].should == @user
      assigns[:api_access_token].should_not be_nil
      tokens.should include(assigns[:access_token].id)

      response.code.should == '200'
    end

    it "should return unauthorized and not create access_token on failed login" do
      post(:test_login_access_token, :username => 'gizmo', :password => 'wrong_secret',
           :format => :json)

      assigns[:current_user].should be_nil
      assigns[:api_access_token].should be_nil
      @user.access_tokens(true).count.should == 0

      response.code.should == '401'
    end

    # Logout

    it "should destroy access token on logout" do
      subject.auto_login(@user, true)
      api_access_token = @user.access_tokens.first

      post(:test_logout_access_token, :access_token => api_access_token.token,
           :format => :json)

      assigns[:current_user].should be_nil
      assigns[:api_access_token].should be_nil
      @user.access_tokens(true).count.should == 0

      response.code.should == '200'
    end

    # Requests with valid access token

    it "should allow request with valid access token" do
      subject.auto_login(@user, true)
      api_access_token = @user.access_tokens.first

      get(:test_action_access_token, :access_token => api_access_token.token,
          :format => :json)

      assigns[:current_user].should == @user
      assigns[:api_access_token].token.should == api_access_token.token

      response.code.should == '200'
    end

    it "should update last activity time of valid token if setting is enabled" do
      sorcery_model_property_set(:access_token_duration_from_last_activity, true)
      api_access_token = @user.create_access_token!
      api_access_token.last_activity_at = Time.zone.now - 60
      api_access_token.save!

      get(:test_action_access_token, :access_token => api_access_token.token,
          :format => :json)

      assigns[:current_user].should == @user
      assigns[:api_access_token].token.should == api_access_token.token

      assigns[:api_access_token].last_activity_at.should > api_access_token.last_activity_at

      response.code.should == '200'
    end

    it "should not update last_activity time of valid token if setting is disabled" do
      sorcery_model_property_set(:access_token_duration_from_last_activity, false)
      api_access_token = @user.create_access_token!
      api_access_token.last_activity_at = Time.zone.now - 60
      api_access_token.save!

      get(:test_action_access_token, :access_token => api_access_token.token,
          :format => :json)

      assigns[:current_user].should == @user
      assigns[:api_access_token].token.should == api_access_token.token

      prev_time = api_access_token.last_activity_at
      assigns[:api_access_token].last_activity_at.to_i.should == prev_time.to_i

      response.code.should == '200'

    end

    # Requests with invalid access token

    it "should deny request with nonexistent access token" do
      api_access_token = @user.create_access_token!
      get(:test_action_access_token, :access_token => api_access_token.token + '_invalid',
          :format => :json)

      assigns[:current_user].should be_false
      assigns[:api_access_token].should be_nil

      response.code.should == '401'
    end

    it "should deny request with expired access token (against created_at)" do
      sorcery_model_property_set(:access_token_duration_from_last_activity, false)
      api_access_token = @user.create_access_token!
      api_access_token.created_at = Time.zone.now - 2.days
      api_access_token.save!

      get(:test_action_access_token, :access_token => api_access_token.token,
          :format => :json)

      assigns[:current_user].should be_false
      assigns[:api_access_token].should be_nil

      response.code.should == '401'
    end

    it "should deny request with expired access token (against last_activity_at)" do
      sorcery_model_property_set(:access_token_duration_from_last_activity, true)
      api_access_token = @user.create_access_token!
      api_access_token.last_activity_at = Time.zone.now - 2.days
      api_access_token.save!

      get(:test_action_access_token, :access_token => api_access_token.token,
          :format => :json)

      assigns[:current_user].should be_false
      assigns[:api_access_token].should be_nil

      response.code.should == '401'
    end

    specify { should respond_to(:auto_login) }

    it "auto_login(user) should login a user instance without creating an access token" do
      subject.auto_login(@user)
      assigns[:current_user].should == @user
      assigns[:api_access_token].should be_nil
    end

    it "auto_login(user, true) should login a user instance and create an access token" do
      subject.auto_login(@user, true)
      assigns[:current_user].should == @user
      assigns[:api_access_token].should_not be_nil
      assigns[:api_access_token].should == @user.access_tokens(true).first
    end
  end
end
