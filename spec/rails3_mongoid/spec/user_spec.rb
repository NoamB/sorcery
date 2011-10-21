require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/../app/mailers/sorcery_mailer')
require File.expand_path(File.dirname(__FILE__) + '/../../shared_examples/user_shared_examples')

describe "User with no submodules (core)" do
  before(:all) do
    sorcery_reload!
  end

  describe User, "when app has plugin loaded" do
    it "User should respond_to .authenticates_with_sorcery!" do
      User.should respond_to(:authenticates_with_sorcery!)
    end
  end
  
  # ----------------- PLUGIN CONFIGURATION -----------------------
  
  it_should_behave_like "rails_3_core_model"
  
  describe User, "external users" do

    it_should_behave_like "external_user"
    
  end

  describe User, "when inherited" do
    it "should inherit mongoid fields" do
      User.class_eval do
        field :blabla
      end
      class SubUser < User
      end

      SubUser.fields.should include("blabla")
    end
  end
  
  describe User, "mongoid adapter" do
    before(:each) do
      create_new_user
      @user = User.first
    end
    
    after(:each) do
      User.delete_all
    end
    
    it "find_by_username should work as expected" do
      User.find_by_username("gizmo").should == @user
    end
    
    it "find_by_username should work as expected with multiple username attributes" do
      sorcery_model_property_set(:username_attribute_names, [:username, :email])
      User.find_by_username("gizmo").should == @user
    end
    
    it "find_by_email should work as expected" do
      User.find_by_username("bla@bla.com").should == @user
    end
  end
end