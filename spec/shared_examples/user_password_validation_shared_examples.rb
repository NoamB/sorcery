shared_examples_for "rails_3_password_validation_model" do
  let(:user) { create_new_user({:username => 'foo_bar', :email => "foo@bar.com", :password => 'foobar'})}

  describe "loaded plugin configuration" do

    before(:all) do
      sorcery_reload!([:password_validation])
    end
  
    after(:each) do
      User.sorcery_config.reset!
    end
    
    specify { expect(user).to respond_to :validate_password! }
    specify { expect(user).to respond_to :valid_password? }
    
    
    it "returns true if password is correct" do
      expect(user.valid_password?("foobar")).to be true
    end
  
    it "returns false if password is incorrect" do
      expect(user.valid_password?("foobug")).to be false
    end

    it "raise error if password is incorrect with bang method" do
      expect{user.validate_password!("foobug")}.to raise_error Sorcery::Model::Submodules::PasswordValidation::ValidationError
    end

  end
end