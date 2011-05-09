module Sorcery
  module CryptoProviders
    module Common
      def self.included(base)
        base.class_eval do
          class << self
            attr_accessor :join_token

            # The number of times to loop through the encryption.
            def stretches
              @stretches ||= 1
            end
            attr_writer :stretches

            def encrypt(*tokens)
              digest = tokens.flatten.compact.join(join_token)
              stretches.times { digest = secure_digest(digest) }
              digest
            end

            # Does the crypted password match the tokens? Uses the same tokens that were used to encrypt.
            def matches?(crypted, *tokens)
              encrypt(*tokens.compact) == crypted
            end

            def reset!
              @stretches = 1
              @join_token = nil
            end
          end
        end
      end
    end
  end
end