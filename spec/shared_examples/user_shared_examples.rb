shared_examples_for "rails_3_core_model" do
  describe User, "loaded plugin configuration" do
    after(:each) do
      User.sorcery_config.reset!
    end

    it "should enable configuration option 'username_attribute_names'" do
      sorcery_model_property_set(:username_attribute_names, :email)
      User.sorcery_config.username_attribute_names.should == [:email]
    end

    it "should enable configuration option 'password_attribute_name'" do
      sorcery_model_property_set(:password_attribute_name, :mypassword)
      User.sorcery_config.password_attribute_name.should equal(:mypassword)
    end

    it "should enable configuration option 'email_attribute_name'" do
      sorcery_model_property_set(:email_attribute_name, :my_email)
      User.sorcery_config.email_attribute_name.should equal(:my_email)
    end

    it "should enable configuration option 'crypted_password_attribute_name'" do
      sorcery_model_property_set(:crypted_password_attribute_name, :password)
      User.sorcery_config.crypted_password_attribute_name.should equal(:password)
    end

    it "should enable configuration option 'salt_attribute_name'" do
      sorcery_model_property_set(:salt_attribute_name, :my_salt)
      User.sorcery_config.salt_attribute_name.should equal(:my_salt)
    end

    it "should enable configuration option 'encryption_algorithm'" do
      sorcery_model_property_set(:encryption_algorithm, :none)
      User.sorcery_config.encryption_algorithm.should equal(:none)
    end

    it "should enable configuration option 'encryption_key'" do
      sorcery_model_property_set(:encryption_key, 'asdadas424234242')
      User.sorcery_config.encryption_key.should == 'asdadas424234242'
    end

    it "should enable configuration option 'custom_encryption_provider'" do
      sorcery_model_property_set(:encryption_algorithm, :custom)
      sorcery_model_property_set(:custom_encryption_provider, Array)
      User.sorcery_config.custom_encryption_provider.should equal(Array)
    end

    it "should enable configuration option 'salt_join_token'" do
      salt_join_token = "--%%*&-"
      sorcery_model_property_set(:salt_join_token, salt_join_token)
      User.sorcery_config.salt_join_token.should equal(salt_join_token)
    end

    it "should enable configuration option 'stretches'" do
      stretches = 15
      sorcery_model_property_set(:stretches, stretches)
      User.sorcery_config.stretches.should equal(stretches)
    end
  end

  # ----------------- PLUGIN ACTIVATED -----------------------
  describe User, "when activated with sorcery" do
    before(:all) do
      sorcery_reload!
    end

    before(:each) do
      User.delete_all
    end

    it "should respond to class method authenticate" do
      ActiveRecord::Base.should_not respond_to(:authenticate) if defined?(ActiveRecord)
      User.should respond_to(:authenticate)
    end

    it "authenticate should return true if credentials are good" do
      create_new_user
      User.authenticate(@user.send(User.sorcery_config.username_attribute_names.first), 'secret').should be_true
    end

    it "authenticate should return false if credentials are bad" do
      create_new_user
      User.authenticate(@user.send(User.sorcery_config.username_attribute_names.first), 'wrong!').should be_false
    end

    context "with empty credentials" do
      before do
        sorcery_model_property_set(:downcase_username_before_authenticating, true)
      end

      after do
        sorcery_reload!
      end

      it "don't downcase empty credentials" do
        expect(User.authenticate(nil, 'wrong!')).to be_false
      end
    end

    specify { User.should respond_to(:encrypt) }

    it "subclass should inherit config if defined so" do
      sorcery_reload!([],{:subclasses_inherit_config => true})
      class Admin < User
      end
      Admin.sorcery_config.should_not be_nil
      Admin.sorcery_config.should == User.sorcery_config
    end

    it "subclass should not inherit config if not defined so" do
      sorcery_reload!([],{:subclasses_inherit_config => false})
      class Admin2 < User
      end
      Admin2.sorcery_config.should be_nil
    end
  end

  # ----------------- REGISTRATION -----------------------
  describe User, "registration" do

    before(:all) do
      sorcery_reload!()
    end

    before(:each) do
      User.delete_all
    end

    it "by default, encryption_provider should not be nil" do
      User.sorcery_config.encryption_provider.should_not be_nil
    end

    it "should encrypt password when a new user is saved" do
      create_new_user
      User.sorcery_config.encryption_provider.matches?(@user.send(User.sorcery_config.crypted_password_attribute_name),'secret',@user.salt).should be_true
    end

    it "should clear the virtual password field if the encryption process worked" do
      create_new_user
      @user.password.should be_nil
    end

    it "should not clear the virtual password field if save failed due to validity" do
      create_new_user
      User.class_eval do
        validates_format_of :email, :with => /\A(.)+@(.)+\Z/, :if => Proc.new {|r| r.email}, :message => "is invalid"
      end
      @user.password = 'blupush'
      @user.email = 'asd'
      @user.save
      @user.password.should_not be_nil
    end

    it "should not clear the virtual password field if save failed due to exception" do
      create_new_user
      @user.password = '4blupush'
      @user.username = nil
      User.class_eval do
        validates_presence_of :username
      end
      begin
        @user.save! # triggers validation exception since username field is required.
      rescue
      end
      @user.password.should_not be_nil
    end

    it "should not encrypt the password twice when a user is updated" do
      create_new_user
      @user.email = "blup@bla.com"
      @user.save!
      User.sorcery_config.encryption_provider.matches?(@user.send(User.sorcery_config.crypted_password_attribute_name),'secret',@user.salt).should be_true
    end

    it "should replace the crypted_password in case a new password is set" do
      create_new_user
      @user.password = 'new_secret'
      @user.save!
      User.sorcery_config.encryption_provider.matches?(@user.send(User.sorcery_config.crypted_password_attribute_name),'secret',@user.salt).should be_false
    end

  end

  # ----------------- PASSWORD ENCRYPTION -----------------------
  describe User, "special encryption cases" do
    before(:all) do
      sorcery_reload!()
      @text = "Some Text!"
    end

    before(:each) do
      User.delete_all
    end

    after(:each) do
      User.sorcery_config.reset!
    end

    it "should work with no password encryption" do
      sorcery_model_property_set(:encryption_algorithm, :none)
      create_new_user
      User.authenticate(@user.send(User.sorcery_config.username_attribute_names.first), 'secret').should be_true
    end

    it "should work with custom password encryption" do
      class MyCrypto
        def self.encrypt(*tokens)
          tokens.flatten.join('').gsub(/e/,'A')
        end

        def self.matches?(crypted,*tokens)
          crypted == encrypt(*tokens)
        end
      end
      sorcery_model_property_set(:encryption_algorithm, :custom)
      sorcery_model_property_set(:custom_encryption_provider, MyCrypto)
      create_new_user
      User.authenticate(@user.send(User.sorcery_config.username_attribute_names.first), 'secret').should be_true
    end

    it "if encryption algo is aes256, it should set key to crypto provider" do
      sorcery_model_property_set(:encryption_algorithm, :aes256)
      sorcery_model_property_set(:encryption_key, nil)
      expect{User.encrypt(@text)}.to raise_error(ArgumentError)
      sorcery_model_property_set(:encryption_key, "asd234dfs423fddsmndsflktsdf32343")
      expect{User.encrypt(@text)}.to_not raise_error
    end

    it "if encryption algo is aes256, it should set key to crypto provider, even if attributes are set in reverse" do
      sorcery_model_property_set(:encryption_key, nil)
      sorcery_model_property_set(:encryption_algorithm, :none)
      sorcery_model_property_set(:encryption_key, "asd234dfs423fddsmndsflktsdf32343")
      sorcery_model_property_set(:encryption_algorithm, :aes256)
      expect{User.encrypt(@text)}.to_not raise_error
    end

    it "if encryption algo is md5 it should work" do
      sorcery_model_property_set(:encryption_algorithm, :md5)
      User.encrypt(@text).should == Sorcery::CryptoProviders::MD5.encrypt(@text)
    end

    it "if encryption algo is sha1 it should work" do
      sorcery_model_property_set(:encryption_algorithm, :sha1)
      User.encrypt(@text).should == Sorcery::CryptoProviders::SHA1.encrypt(@text)
    end

    it "if encryption algo is sha256 it should work" do
      sorcery_model_property_set(:encryption_algorithm, :sha256)
      User.encrypt(@text).should == Sorcery::CryptoProviders::SHA256.encrypt(@text)
    end

    it "if encryption algo is sha512 it should work" do
      sorcery_model_property_set(:encryption_algorithm, :sha512)
      User.encrypt(@text).should == Sorcery::CryptoProviders::SHA512.encrypt(@text)
    end

    it "salt should be random for each user and saved in db" do
      sorcery_model_property_set(:salt_attribute_name, :salt)
      create_new_user
      @user.salt.should_not be_nil
    end

    it "if salt is set should use it to encrypt" do
      sorcery_model_property_set(:salt_attribute_name, :salt)
      sorcery_model_property_set(:encryption_algorithm, :sha512)
      create_new_user
      @user.crypted_password.should_not == Sorcery::CryptoProviders::SHA512.encrypt('secret')
      @user.crypted_password.should == Sorcery::CryptoProviders::SHA512.encrypt('secret',@user.salt)
    end

    it "if salt_join_token is set should use it to encrypt" do
      sorcery_model_property_set(:salt_attribute_name, :salt)
      sorcery_model_property_set(:salt_join_token, "-@=>")
      sorcery_model_property_set(:encryption_algorithm, :sha512)
      create_new_user
      @user.crypted_password.should_not == Sorcery::CryptoProviders::SHA512.encrypt('secret')
      Sorcery::CryptoProviders::SHA512.join_token = ""
      @user.crypted_password.should_not == Sorcery::CryptoProviders::SHA512.encrypt('secret',@user.salt)
      Sorcery::CryptoProviders::SHA512.join_token = User.sorcery_config.salt_join_token
      @user.crypted_password.should == Sorcery::CryptoProviders::SHA512.encrypt('secret',@user.salt)
    end

  end

  describe User, "ORM adapter" do
    before(:all) do
      sorcery_reload!()
      User.delete_all
    end

    before(:each) do
      create_new_user
    end

    after(:each) do
      User.delete_all
      User.sorcery_config.reset!
    end

    it "find_by_username should work as expected" do
      sorcery_model_property_set(:username_attribute_names, [:username])
      User.find_by_username("gizmo").should == @user
    end

    it "find_by_username should work as expected with multiple username attributes" do
      sorcery_model_property_set(:username_attribute_names, [:username, :email])
      User.find_by_username("gizmo").should == @user
    end

    it "find_by_email should work as expected" do
      User.find_by_email("bla@bla.com").should == @user
    end
  end
end

shared_examples_for "external_user" do
  before(:each) do
    User.delete_all
  end

  it "should respond to 'external?'" do
    create_new_user
    @user.should respond_to(:external?)
  end

  it "external? should be false for regular users" do
    create_new_user
    @user.external?.should be_false
  end

  it "external? should be true for external users" do
    create_new_external_user(:twitter)
    @user.external?.should be_true
  end
end