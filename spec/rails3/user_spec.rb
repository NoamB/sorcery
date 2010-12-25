require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe User, "when app has plugin loaded" do
  it "should respond to the plugin activation class method" do
    ActiveRecord::Base.should respond_to(:activate_simple_auth!)
    User.should respond_to(:activate_simple_auth!)
  end
end

describe User, "plugin activation" do
  it "should enable configuration option 'username_attribute_name'" do
    SimpleAuth::ORM::Config.username_attribute_name.should equal(:username)
    
    class User
      activate_simple_auth! do |config|
        config.username_attribute_name = :email
      end
    end
    
    SimpleAuth::ORM::Config.username_attribute_name.should equal(:email)
  end
end

describe User, "when activated with simple_auth" do
  it "should respond to class method authentic?" do
    ActiveRecord::Base.should_not respond_to(:authentic?)
    User.should respond_to(:authentic?)
  end
  
  # it "authentic? should return true if credentials are good" do
  #   @user = users(:noam)
  #   User.authentic?(@user.username, 'secret').should be_true
  # end
end