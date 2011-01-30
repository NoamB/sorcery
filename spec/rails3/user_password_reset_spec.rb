require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "User with password_reset submodule" do
  before(:all) do
    ActiveRecord::Migrator.migrate("#{Rails.root}/db/migrate/core")
    ActiveRecord::Migrator.migrate("#{Rails.root}/db/migrate/password_reset")
  end
  
  after(:all) do
    ActiveRecord::Migrator.rollback("#{Rails.root}/db/migrate/password_reset")
    ActiveRecord::Migrator.rollback("#{Rails.root}/db/migrate/core")
  end

  # ----------------- PLUGIN CONFIGURATION -----------------------
  describe User, "loaded plugin configuration" do
  
    before(:all) do
      plugin_model_configure([:password_reset], :sorcery_mailer => ::SorceryMailer)
    end
  
    after(:each) do
      User.sorcery_config.reset!
    end
    
    it "should respond to 'reset_password!'" do
      create_new_user
      @user.should respond_to(:reset_password!)
    end
  end

  # ----------------- PLUGIN ACTIVATED -----------------------
  describe User, "when activated with sorcery" do
  
    before(:all) do
      plugin_model_configure([:password_reset], :sorcery_mailer => ::SorceryMailer)
    end
  
    before(:each) do
      User.delete_all
    end

    it "'reset_password!' should generate a reset_password_code" do
      create_new_user
      @user.reset_password_code.should be_nil
      @user.reset_password!
      @user.reset_password_code.should_not be_nil
    end

    it "the reset_password_code should be random" do
      create_new_user
      @user.reset_password!
      old_password_code = @user.reset_password_code
      @user.reset_password!
      @user.reset_password_code.should_not == old_password_code
    end

    it "should send an email on reset" do
      create_new_user
      old_size = ActionMailer::Base.deliveries.size
      @user.reset_password!
      ActionMailer::Base.deliveries.size.should == old_size + 1
    end

    it "when a new password is set, should delete reset_password_code" do
      create_new_user
      @user.reset_password!
      @user.reset_password_code.should_not be_nil
      @user.password = "blabulsdf"
      @user.save!
      @user.reset_password_code.should be_nil
    end
    
    it "if mailer is nil on activation, throw exception!" do
      expect{plugin_model_configure([:password_reset])}.to raise_error(ArgumentError)
    end
  end
  
end