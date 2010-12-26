require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Crypto Providers" do

  describe SimpleAuth::CryptoProviders::MD5 do
    
    after(:each) do
      SimpleAuth::CryptoProviders::MD5.reset_to_defaults!
    end
    
    it "encrypt works via wrapper like normal lib" do
      SimpleAuth::CryptoProviders::MD5.encrypt('Noam Ben-Ari').should == Digest::MD5.hexdigest('Noam Ben-Ari')
    end
    
    it "works with multiple stretches" do
      SimpleAuth::CryptoProviders::MD5.stretches = 3
      SimpleAuth::CryptoProviders::MD5.encrypt('Noam Ben-Ari').should == Digest::MD5.hexdigest(Digest::MD5.hexdigest(Digest::MD5.hexdigest('Noam Ben-Ari')))
    end
    
    it "matches? returns true when matches" do
      SimpleAuth::CryptoProviders::MD5.matches?(Digest::MD5.hexdigest('Noam Ben-Ari'), 'Noam Ben-Ari').should be_true
    end
    
    it "matches? returns false when no match" do
      SimpleAuth::CryptoProviders::MD5.matches?(Digest::MD5.hexdigest('Noam Ben-Ari'), 'Some Dude').should be_false
    end
    
  end
  
  describe SimpleAuth::CryptoProviders::SHA1 do
    
    before(:all) do
      @digest = 'Noam Ben-Ari'
      10.times {@digest = Digest::SHA1.hexdigest(@digest)}
    end
    
    after(:each) do
      SimpleAuth::CryptoProviders::SHA1.reset_to_defaults!
    end
    
    it "encrypt works via wrapper like normal lib" do
      SimpleAuth::CryptoProviders::SHA1.encrypt('Noam Ben-Ari').should == @digest
    end
    
    it "works with multiple stretches" do
      SimpleAuth::CryptoProviders::SHA1.stretches = 3
      SimpleAuth::CryptoProviders::SHA1.encrypt('Noam Ben-Ari').should == Digest::SHA1.hexdigest(Digest::SHA1.hexdigest(Digest::SHA1.hexdigest('Noam Ben-Ari')))
    end
    
    it "matches? returns true when matches" do
      SimpleAuth::CryptoProviders::SHA1.matches?(@digest, 'Noam Ben-Ari').should be_true
    end
    
    it "matches? returns false when no match" do
      SimpleAuth::CryptoProviders::SHA1.matches?(@digest, 'Some Dude').should be_false
    end
    
  end

end
