require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe User, "when app has plugin loaded" do
  it "should respond to the plugin activation class method" do
    ActiveRecord::Base.should respond_to(:activate_simple_auth!)
    User.should respond_to(:activate_simple_auth!)
  end
end

describe User, "plugin configuration" do
  after(:each) do
    SimpleAuth::Model::Config.reset!
  end
  
  it "should enable submodules in parameters" do
    plugin_model_configure([:password_confirmation])
    SimpleAuth::Model::Config.should respond_to(:password_confirmation_attribute_name)
  end
  
  it "should enable configuration option 'username_attribute_name'" do
    plugin_set_model_config_property(:username_attribute_name, :email)
    SimpleAuth::Model::Config.username_attribute_name.should equal(:email)    
  end
  
  it "should enable configuration option 'password_attribute_name'" do
    plugin_set_model_config_property(:password_attribute_name, :mypassword)
    SimpleAuth::Model::Config.password_attribute_name.should equal(:mypassword)
  end
  
  it "should enable configuration option 'password_confirmation_attribute_name'" do
    plugin_set_model_config_property(:password_confirmation_attribute_name, :mypassword_conf)
    SimpleAuth::Model::Config.password_confirmation_attribute_name.should equal(:mypassword_conf)
  end
  
  it "should enable configuration option 'crypted_password_attribute_name'" do
    plugin_set_model_config_property(:crypted_password_attribute_name, :password)
    SimpleAuth::Model::Config.crypted_password_attribute_name.should equal(:password)
  end
  
  it "should enable configuration option 'encryption_algorithm'" do
    plugin_set_model_config_property(:encryption_algorithm, :none)
    SimpleAuth::Model::Config.encryption_algorithm.should equal(:none)
  end
  
  it "should enable configuration option 'encryption_key'" do
    plugin_set_model_config_property(:encryption_key, 'asdadas424234242')
    SimpleAuth::Model::Config.encryption_key.should == 'asdadas424234242'
  end
  
  it "should enable configuration option 'custom_encryption_provider'" do
    plugin_set_model_config_property(:encryption_algorithm, :custom)
    plugin_set_model_config_property(:custom_encryption_provider, Array)
    SimpleAuth::Model::Config.custom_encryption_provider.should equal(Array)
  end
  
end

describe User, "when activated with simple_auth" do
  before(:each) do
    User.delete_all
  end
  
  it "should respond to the class method encrypt" do
    User.should respond_to(:encrypt)
  end
  
  it "should respond to class method authentic?" do
    ActiveRecord::Base.should_not respond_to(:authentic?)
    User.should respond_to(:authentic?)
  end
  
  it "authentic? should return true if credentials are good" do
    create_new_user
    User.authentic?(@user.send(SimpleAuth::Model::Config.username_attribute_name), 'secret').should be_true
  end
  
  it "authentic? should return false if credentials are bad" do
    create_new_user
    User.authentic?(@user.send(SimpleAuth::Model::Config.username_attribute_name), 'wrong!').should be_false
  end
  
end

describe User, "registration" do
  before(:all) do
    plugin_model_configure
  end
  
  before(:each) do
    User.delete_all
  end
  
  it "should encrypt password when a new user is saved" do
    create_new_user
    @user.send(SimpleAuth::Model::Config.crypted_password_attribute_name).should == User.encrypt('secret')
  end
  
  it "should not encrypt the password twice when a user is updated" do
    create_new_user
    @user.email = "blup@bla.com"
    @user.save!
    @user.send(SimpleAuth::Model::Config.crypted_password_attribute_name).should == User.encrypt('secret')
  end
  
  it "should replace the crypted_password in case a new password is set" do
    create_new_user
    @user.password = 'new_secret'
    @user.save!
    @user.send(SimpleAuth::Model::Config.crypted_password_attribute_name).should == User.encrypt('new_secret')
  end
  
  describe "with password_confirmation module" do
    it "should replace the crypted_password in case a new password is set" do
      plugin_model_configure([:password_confirmation])
      create_new_user
      @user.password = 'new_secret'
      @user.password_confirmation = 'new_secret'
      @user.save!
      @user.send(SimpleAuth::Model::Config.crypted_password_attribute_name).should == User.encrypt('new_secret')
    end
  end
end

describe User, "password confirmation" do
  before(:each) do
    User.delete_all
  end
  
  after(:each) do
    SimpleAuth::Model::Config.reset!
  end
  
  it "should not register a user with mismatching password fields" do
    plugin_model_configure([:password_confirmation])
    @user = User.new(:username => 'gizmo', :email => "bla@bla.com", :password => 'secret', :password_confirmation => 'secrer')
    @user.valid?.should == false
    @user.save.should == false
    expect{@user.save!}.to raise_error(ActiveRecord::RecordInvalid)
  end
end

describe User, "special encryption cases" do
  before(:all) do
    @text = "Some Text!"
  end
  
  before(:each) do
    User.delete_all
  end
  
  after(:each) do
    SimpleAuth::Model::Config.reset!
  end
  
  it "should work with no password encryption" do
    plugin_set_model_config_property(:encryption_algorithm, :none)
    create_new_user
    User.authentic?(@user.send(SimpleAuth::Model::Config.username_attribute_name), 'secret').should be_true
  end
  
  it "should work with custom password encryption" do
    class MyCrypto
      def self.encrypt(*tokens)
        tokens.flatten.join('').gsub(/e/,'A')
      end
    end
    plugin_set_model_config_property(:encryption_algorithm, :custom)
    plugin_set_model_config_property(:custom_encryption_provider, MyCrypto)
    create_new_user
    User.authentic?(@user.send(SimpleAuth::Model::Config.username_attribute_name), 'secret').should be_true
  end
  
  it "if encryption algo is aes256, it should set key to crypto provider" do
    plugin_set_model_config_property(:encryption_algorithm, :aes256)
    plugin_set_model_config_property(:encryption_key, nil)
    expect{User.encrypt(@text)}.to raise_error(ArgumentError)
    plugin_set_model_config_property(:encryption_key, "asd234dfs423fddsmndsflktsdf32343")
    expect{User.encrypt(@text)}.to_not raise_error(ArgumentError)
  end
  
  it "if encryption algo is md5 it should work" do
    plugin_set_model_config_property(:encryption_algorithm, :md5)
    User.encrypt(@text).should == SimpleAuth::CryptoProviders::MD5.encrypt(@text)
  end
  
  it "if encryption algo is sha1 it should work" do
    plugin_set_model_config_property(:encryption_algorithm, :sha1)
    User.encrypt(@text).should == SimpleAuth::CryptoProviders::SHA1.encrypt(@text)
  end
  
  it "if encryption algo is sha256 it should work" do
    plugin_set_model_config_property(:encryption_algorithm, :sha256)
    User.encrypt(@text).should == SimpleAuth::CryptoProviders::SHA256.encrypt(@text)
  end
  
  it "if encryption algo is sha512 it should work" do
    plugin_set_model_config_property(:encryption_algorithm, :sha512)
    User.encrypt(@text).should == SimpleAuth::CryptoProviders::SHA512.encrypt(@text)
  end
  
end