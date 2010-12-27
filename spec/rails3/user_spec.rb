require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe User, "when app has plugin loaded" do
  it "should respond to the plugin activation class method" do
    ActiveRecord::Base.should respond_to(:activate_simple_auth!)
    User.should respond_to(:activate_simple_auth!)
  end
end

def plugin_set_config_property(property, value)
  User.class_eval do
    activate_simple_auth! do |config|
      config.send("#{property}=".to_sym, value)
    end
  end
end

describe User, "plugin configuration" do
  after(:each) do
    SimpleAuth::ORM::Config.reset_to_defaults!
  end
  
  it "should enable configuration option 'username_attribute_name'" do    
    plugin_set_config_property(:username_attribute_name, :email)
    SimpleAuth::ORM::Config.username_attribute_name.should equal(:email)
  end
  
  it "should verify/make 'username_attribute_name' is unique in the DB" do
    pending
  end
  
  it "should enable configuration option 'crypted_password_attribute_name'" do    
    plugin_set_config_property(:crypted_password_attribute_name, :password)
    SimpleAuth::ORM::Config.crypted_password_attribute_name.should equal(:password)
  end
  
  it "should enable configuration option 'encryption_algorithm'" do    
    plugin_set_config_property(:encryption_algorithm, :none)
    SimpleAuth::ORM::Config.encryption_algorithm.should equal(:none)
  end
  
  it "should enable configuration option 'encryption_key'" do    
    plugin_set_config_property(:encryption_key, 'asdadas424234242')
    SimpleAuth::ORM::Config.encryption_key.should == 'asdadas424234242'
  end
  
  it "should enable configuration option 'custom_encryption_provider'" do    
    plugin_set_config_property(:encryption_algorithm, :custom)
    plugin_set_config_property(:custom_encryption_provider, Array)
    SimpleAuth::ORM::Config.custom_encryption_provider.should equal(Array)
  end
end

describe User, "when activated with simple_auth" do
  
  it "should respond to the class method encrypt" do
    User.should respond_to(:encrypt)
  end
  
  it "should respond to class method authentic?" do
    ActiveRecord::Base.should_not respond_to(:authentic?)
    User.should respond_to(:authentic?)
  end
  
  it "authentic? should return true if credentials are good" do
    @user = User.new(:username => 'gizmo', :email => "bla@bla.com", :crypted_password => User.encrypt('secret'))
    @user.save!
    User.authentic?(@user.send(SimpleAuth::ORM::Config.username_attribute_name), 'secret').should be_true
  end
  
  it "authentic? should return false if credentials are bad" do
    @user = User.new(:username => 'gizmo', :email => "bla@bla.com", :crypted_password => User.encrypt('secret'))
    @user.save!
    User.authentic?(@user.send(SimpleAuth::ORM::Config.username_attribute_name), 'wrong!').should be_false
  end
end

describe "special encryption cases" do
  before(:all) do
    @text = "Some Text!"
  end
  
  after(:each) do
    SimpleAuth::ORM::Config.reset_to_defaults!
  end
  
  it "should work with no password encryption" do
    plugin_set_config_property(:encryption_algorithm, :none)
    @user = User.new(:username => 'gizmo', :email => "bla@bla.com", :crypted_password => 'secret')
    @user.save!
    User.authentic?(@user.send(SimpleAuth::ORM::Config.username_attribute_name), 'secret').should be_true
  end
  
  it "should work with custom password encryption" do
    class MyCrypto
      def self.encrypt(*tokens)
        tokens.flatten.join('').gsub(/e/,'A')
      end
    end
    plugin_set_config_property(:encryption_algorithm, :custom)
    plugin_set_config_property(:custom_encryption_provider, MyCrypto)
    @user = User.new(:username => 'gizmo', :email => "bla@bla.com", :crypted_password => MyCrypto.encrypt('secret'))
    @user.save!
    User.authentic?(@user.send(SimpleAuth::ORM::Config.username_attribute_name), 'secret').should be_true
  end
  
  it "if encryption algo is aes256, it should set key to crypto provider" do
    plugin_set_config_property(:encryption_algorithm, :aes256)
    plugin_set_config_property(:encryption_key, nil)
    expect{User.encrypt(@text)}.to raise_error(ArgumentError)
    plugin_set_config_property(:encryption_key, "asd234dfs423fddsmndsflktsdf32343")
    expect{User.encrypt(@text)}.to_not raise_error(ArgumentError)
  end
  
  it "if encryption algo is md5 it should work" do
    plugin_set_config_property(:encryption_algorithm, :md5)
    User.encrypt(@text).should == SimpleAuth::CryptoProviders::MD5.encrypt(@text)
  end
  
  it "if encryption algo is sha1 it should work" do
    plugin_set_config_property(:encryption_algorithm, :sha1)
    User.encrypt(@text).should == SimpleAuth::CryptoProviders::SHA1.encrypt(@text)
  end
  
  it "if encryption algo is sha256 it should work" do
    plugin_set_config_property(:encryption_algorithm, :sha256)
    User.encrypt(@text).should == SimpleAuth::CryptoProviders::SHA256.encrypt(@text)
  end
  
  it "if encryption algo is sha512 it should work" do
    plugin_set_config_property(:encryption_algorithm, :sha512)
    User.encrypt(@text).should == SimpleAuth::CryptoProviders::SHA512.encrypt(@text)
  end
  
end