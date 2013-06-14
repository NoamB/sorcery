require "digest/sha1"

module Sorcery
  module CryptoProviders
    # This class was made for the users transitioning from restful_authentication. I highly discourage using this
    # crypto provider as it inferior to your other options. Please use any other provider offered by Sorcery.
    class SHA1
      include Common
      class << self
        def join_token
          @join_token ||= "--"
        end

        # Turns your raw password into a Sha1 hash.
        def encrypt(*tokens)
          digest = ''
          password = tokens.first
          salt = tokens.last
          pepper = ''
          stretches.times { digest = secure_digest(salt, digest, password, pepper) }
          digest
        end

        def secure_digest(*tokens)
          Digest::SHA1.hexdigest('--' << tokens.flatten.join('--') << '--')
        end

      end
    end
  end
end