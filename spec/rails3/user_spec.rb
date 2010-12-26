require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'digest/md5'

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
    SimpleAuth::ORM::Config.username_attribute_name.should equal(:username)
    
    plugin_set_config_property(:username_attribute_name, :email)
    
    SimpleAuth::ORM::Config.username_attribute_name.should equal(:email)
  end
  
  it "should verify/make 'username_attribute_name' is unique in the DB" do
    pending
  end
  
  it "should enable configuration option 'crypted_password_attribute_name'" do
    SimpleAuth::ORM::Config.crypted_password_attribute_name.should equal(:crypted_password)
    
    plugin_set_config_property(:crypted_password_attribute_name, :password)
    
    SimpleAuth::ORM::Config.crypted_password_attribute_name.should equal(:password)
  end
  
  it "should enable configuration option 'encryption_algorithm'" do
    SimpleAuth::ORM::Config.encryption_algorithm.should equal(:md5)
    
    plugin_set_config_property(:encryption_algorithm, :none)
    
    SimpleAuth::ORM::Config.encryption_algorithm.should equal(:none)
  end
end

describe User, "when activated with simple_auth" do
  it "should respond to class method authentic?" do
    ActiveRecord::Base.should_not respond_to(:authentic?)
    User.should respond_to(:authentic?)
  end
  
  it "authentic? should return true if credentials are good" do
    @user = User.new(:username => 'gizmo', :email => "bla@bla.com", :crypted_password => Digest::MD5.hexdigest('secret'))
    @user.save!
    User.authentic?(@user.send(SimpleAuth::ORM::Config.username_attribute_name), 'secret').should be_true
  end
  
  it "authentic? should return false if credentials are bad" do
    @user = User.new(:username => 'gizmo', :email => "bla@bla.com", :crypted_password => Digest::MD5.hexdigest('secret'))
    @user.save!
    User.authentic?(@user.send(SimpleAuth::ORM::Config.username_attribute_name), 'wrong!').should be_false
  end
end