require "digest/sha2"

module Sorcery
  # The activate_sorcery method has a custom_crypto_provider configuration option. 
  # This allows you to use any type of encryption you like.
  # Just create a class with a class level encrypt and matches? method. See example below.
  #
  # === Example
  #
  #   class MyAwesomeEncryptionMethod
  #     def self.encrypt(*tokens)
  #       # the tokens passed will be an array of objects, what type of object is irrelevant,
  #       # just do what you need to do with them and return a single encrypted string.
  #       # for example, you will most likely join all of the objects into a single string and then encrypt that string
  #     end
  #
  #     def self.matches?(crypted, *tokens)
  #       # return true if the crypted string matches the tokens.
  #       # depending on your algorithm you might decrypt the string then compare it to the token, or you might
  #       # encrypt the tokens and make sure it matches the crypted string, its up to you
  #     end
  #   end
  module CryptoProviders
    # = Sha512
    #
    # Uses the Sha512 hash algorithm to encrypt passwords.
    class SHA512
      include Common
      class << self
        def secure_digest(digest)
          Digest::SHA512.hexdigest(digest)
        end
      end
    end
  end
end