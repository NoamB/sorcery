require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe User, "when app has plugin loaded" do
  it "should respond to the plugin activation class method" do
    ActiveRecord::Base.should respond_to(:activate_simple_auth!)
    User.should respond_to(:activate_simple_auth!)
  end
end

describe User, "when activated with simple_auth" do
  it "should respond to the plugin added instance methods" do
    pending
  end
end