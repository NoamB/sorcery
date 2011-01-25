require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/app_root/app/mailers/sorcery_mailer')

describe "User with password_encryption submodule" do
  before(:all) do
    ActiveRecord::Migrator.migrate("#{Rails.root}/db/migrate/encryption")
  end
  
  after(:all) do
    ActiveRecord::Migrator.rollback("#{Rails.root}/db/migrate/encryption")
  end

  # ----------------- PLUGIN CONFIGURATION -----------------------
  describe User, "loaded plugin configuration" do
  
    before(:all) do
      plugin_model_configure([:password_encryption])
    end
  
    after(:each) do
      User.sorcery_config.reset!
    end
      
    it "should enable configuration option 'crypted_password_attribute_name'" do
      plugin_set_model_config_property(:crypted_password_attribute_name, :password)
      User.sorcery_config.crypted_password_attribute_name.should equal(:password)
    end
    
    it "should enable configuration option 'salt_attribute_name'" do
      plugin_set_model_config_property(:salt_attribute_name, :my_salt)
      User.sorcery_config.salt_attribute_name.should equal(:my_salt)
    end

    it "should enable configuration option 'encryption_algorithm'" do
      plugin_set_model_config_property(:encryption_algorithm, :none)
      User.sorcery_config.encryption_algorithm.should equal(:none)
    end

    it "should enable configuration option 'encryption_key'" do
      plugin_set_model_config_property(:encryption_key, 'asdadas424234242')
      User.sorcery_config.encryption_key.should == 'asdadas424234242'
    end

    it "should enable configuration option 'custom_encryption_provider'" do
      plugin_set_model_config_property(:encryption_algorithm, :custom)
      plugin_set_model_config_property(:custom_encryption_provider, Array)
      User.sorcery_config.custom_encryption_provider.should equal(Array)
    end
  
    it "should enable configuration option 'salt_join_token'" do
      salt_join_token = "--%%*&-"
      plugin_set_model_config_property(:salt_join_token, salt_join_token)
      User.sorcery_config.salt_join_token.should equal(salt_join_token)
    end
    
    it "should enable configuration option 'stretches'" do
      stretches = 15
      plugin_set_model_config_property(:stretches, stretches)
      User.sorcery_config.stretches.should equal(stretches)
    end
  end

  # ----------------- PLUGIN ACTIVATED -----------------------
  describe User, "when activated with sorcery" do
  
    before(:all) do
      plugin_model_configure([:password_encryption])
    end
  
    before(:each) do
      User.delete_all
    end

    it "should respond to the class method encrypt" do
      User.should respond_to(:encrypt)
    end
  end

  # ----------------- REGISTRATION -----------------------
  describe User, "registration" do
  
    before(:all) do
      plugin_model_configure([:password_encryption])
    end

    before(:each) do
      User.delete_all
    end
  
    it "should encrypt password when a new user is saved" do
      create_new_user
      @user.send(User.sorcery_config.crypted_password_attribute_name).should == User.encrypt('secret')
    end

    it "should clear the virtual password field if the encryption process worked" do
      create_new_user
      @user.password.should be_nil
    end
    
    it "should not clear the virtual password field if save failed due to validity" do
      create_new_user
      User.class_eval do
        validates_format_of :email, :with => /^(.)+@(.)+$/, :if => Proc.new {|r| r.email}, :message => "is invalid"
      end
      @user.password = 'blupush'
      @user.email = 'asd'
      @user.save
      @user.password.should_not be_nil
    end
    
    it "should not clear the virtual password field if save failed due to exception" do
      create_new_user
      @user.password = 'blupush'
      @user.email = nil
      begin
        @user.save # triggers SQL exception since email field is defined not null.
      rescue
      end
      @user.password.should_not be_nil
    end
    
    it "should not encrypt the password twice when a user is updated" do
      create_new_user
      @user.email = "blup@bla.com"
      @user.save!
      @user.send(User.sorcery_config.crypted_password_attribute_name).should == User.encrypt('secret')
    end

    it "should replace the crypted_password in case a new password is set" do
      create_new_user
      @user.password = 'new_secret'
      @user.save!
      @user.send(User.sorcery_config.crypted_password_attribute_name).should == User.encrypt('new_secret')
    end

  end

  # ----------------- PASSWORD ENCRYPTION -----------------------
  describe User, "special encryption cases" do
    before(:all) do
      plugin_model_configure([:password_encryption])
      @text = "Some Text!"
    end
  
    before(:each) do
      User.delete_all
    end
  
    after(:each) do
      User.sorcery_config.reset!
    end
  
    it "should work with no password encryption" do
      plugin_set_model_config_property(:encryption_algorithm, :none)
      create_new_user
      User.authenticate(@user.send(User.sorcery_config.username_attribute_name), 'secret').should be_true
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
      User.authenticate(@user.send(User.sorcery_config.username_attribute_name), 'secret').should be_true
    end
  
    it "if encryption algo is aes256, it should set key to crypto provider" do
      plugin_set_model_config_property(:encryption_algorithm, :aes256)
      plugin_set_model_config_property(:encryption_key, nil)
      expect{User.encrypt(@text)}.to raise_error(ArgumentError)
      plugin_set_model_config_property(:encryption_key, "asd234dfs423fddsmndsflktsdf32343")
      expect{User.encrypt(@text)}.to_not raise_error(ArgumentError)
    end
    
    it "if encryption algo is aes256, it should set key to crypto provider, even if attributes are set in reverse" do
      plugin_set_model_config_property(:encryption_key, nil)
      plugin_set_model_config_property(:encryption_algorithm, :none)
      plugin_set_model_config_property(:encryption_key, "asd234dfs423fddsmndsflktsdf32343")
      plugin_set_model_config_property(:encryption_algorithm, :aes256)
      expect{User.encrypt(@text)}.to_not raise_error(ArgumentError)
    end
  
    it "if encryption algo is md5 it should work" do
      plugin_set_model_config_property(:encryption_algorithm, :md5)
      User.encrypt(@text).should == Sorcery::CryptoProviders::MD5.encrypt(@text)
    end
  
    it "if encryption algo is sha1 it should work" do
      plugin_set_model_config_property(:encryption_algorithm, :sha1)
      User.encrypt(@text).should == Sorcery::CryptoProviders::SHA1.encrypt(@text)
    end
  
    it "if encryption algo is sha256 it should work" do
      plugin_set_model_config_property(:encryption_algorithm, :sha256)
      User.encrypt(@text).should == Sorcery::CryptoProviders::SHA256.encrypt(@text)
    end
  
    it "if encryption algo is sha512 it should work" do
      plugin_set_model_config_property(:encryption_algorithm, :sha512)
      User.encrypt(@text).should == Sorcery::CryptoProviders::SHA512.encrypt(@text)
    end
  
    it "salt should be random for each user and saved in db" do
      plugin_set_model_config_property(:salt_attribute_name, :salt)
      create_new_user
      @user.salt.should_not be_nil
    end
    
    it "if salt is set should use it to encrypt" do
      plugin_set_model_config_property(:salt_attribute_name, :salt)
      plugin_set_model_config_property(:encryption_algorithm, :sha512)
      create_new_user
      @user.crypted_password.should_not == Sorcery::CryptoProviders::SHA512.encrypt('secret')
      @user.crypted_password.should == Sorcery::CryptoProviders::SHA512.encrypt('secret',@user.salt)
    end
    
    it "if salt_join_token is set should use it to encrypt" do
      plugin_set_model_config_property(:salt_attribute_name, :salt)
      plugin_set_model_config_property(:salt_join_token, "-@=>")
      plugin_set_model_config_property(:encryption_algorithm, :sha512)
      create_new_user
      @user.crypted_password.should_not == Sorcery::CryptoProviders::SHA512.encrypt('secret')
      Sorcery::CryptoProviders::SHA512.join_token = ""
      @user.crypted_password.should_not == Sorcery::CryptoProviders::SHA512.encrypt('secret',@user.salt)
      Sorcery::CryptoProviders::SHA512.join_token = User.sorcery_config.salt_join_token
      @user.crypted_password.should == Sorcery::CryptoProviders::SHA512.encrypt('secret',@user.salt)
    end
    
  end
  
  describe User, "prevent non-active login feature" do
    before(:all) do
      ActiveRecord::Migrator.migrate("#{Rails.root}/db/migrate/activation")
      plugin_model_configure([:password_encryption, :user_activation], :sorcery_mailer => ::SorceryMailer)
    end

    after(:all) do
      ActiveRecord::Migrator.rollback("#{Rails.root}/db/migrate/activation")
    end

    it "should not allow a non-active user to authenticate" do
      create_new_user
      User.authenticate(@user.username,'secret').should be_false
    end

    it "should allow a non-active user to authenticate if configured so" do
      create_new_user
      plugin_set_model_config_property(:prevent_non_active_users_to_login, false)
      User.authenticate(@user.username,'secret').should be_true
    end
  end
end