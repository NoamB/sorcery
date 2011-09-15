require "openssl"

module Sorcery
  module CryptoProviders
    # This encryption method is reversible if you have the supplied key. 
    # So in order to use this encryption method you must supply it with a key first.
    # In an initializer, or before your application initializes, you should do the following:
    #
    #   Sorcery::Model::ConfigAES256.key = "my 32 bytes long key"
    #
    # My final comment is that this is a strong encryption method, 
    # but its main weakness is that its reversible. If you do not need to reverse the hash
    # then you should consider Sha512 or BCrypt instead.
    #
    # Keep your key in a safe place, some even say the key should be stored on a separate server.
    # This won't hurt performance because the only time it will try and access the key on the 
    # separate server is during initialization, which only
    # happens once. The reasoning behind this is if someone does compromise your server they 
    # won't have the key also. Basically, you don't want to store the key with the lock.
    class AES256
      class << self
        attr_writer :key
    
        def encrypt(*tokens)
          aes.encrypt
          aes.key = @key
          [aes.update(tokens.join) + aes.final].pack("m").chomp
        end
    
        def matches?(crypted, *tokens)
          decrypt(crypted) == tokens.join
        rescue OpenSSL::CipherError
          false
        end
        
        def decrypt(crypted)
          aes.decrypt
          aes.key = @key
          (aes.update(crypted.unpack("m").first) + aes.final)
        end
    
        private
        
        def aes
          raise ArgumentError.new("#{name} expects a 32 bytes long key. Please use Sorcery::Model::Config.encryption_key to set it.") if ( @key.nil? || @key == "" )
          @aes ||= OpenSSL::Cipher::Cipher.new("AES-256-ECB")
        end
      end
    end
  end
end