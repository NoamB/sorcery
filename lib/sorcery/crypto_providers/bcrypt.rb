require 'bcrypt'

module Sorcery
  module CryptoProviders
    # For most apps Sha512 is plenty secure, but if you are building an app that stores nuclear
    # launch codes you might want to consier BCrypt. This is an extremely
    # secure hashing algorithm, mainly because it is slow.
    # A brute force attack on a BCrypt encrypted password would take much longer than a brute force attack on a
    # password encrypted with a Sha algorithm. Keep in mind you are sacrificing performance by using this,
    # generating a password takes exponentially longer than any
    # of the Sha algorithms. I did some benchmarking to save you some time with your decision:
    #
    #   require "bcrypt"
    #   require "digest"
    #   require "benchmark"
    #
    #   Benchmark.bm(18) do |x|
    #     x.report("BCrypt (cost = 10:") { 100.times { BCrypt::Password.create("mypass", :cost => 10) } }
    #     x.report("BCrypt (cost = 2:") { 100.times { BCrypt::Password.create("mypass", :cost => 2) } }
    #     x.report("Sha512:") { 100.times { Digest::SHA512.hexdigest("mypass") } }
    #     x.report("Sha1:") { 100.times { Digest::SHA1.hexdigest("mypass") } }
    #   end
    #
    #                           user     system      total        real
    #   BCrypt (cost = 10): 10.780000   0.060000  10.840000 ( 11.100289)
    #   BCrypt (cost = 2):  0.180000   0.000000   0.180000 (  0.181914)
    #   Sha512:             0.000000   0.000000   0.000000 (  0.000829)
    #   Sha1:               0.000000   0.000000   0.000000 (  0.000395)
    #
    # You can play around with the cost to get that perfect balance between performance and security.
    #
    # Decided BCrypt is for you? Just insall the bcrypt gem:
    #
    #   gem install bcrypt-ruby
    #
    # Update your initializer to use it:
    #
    #   config.encryption_algorithm = :bcrypt
    #
    # You are good to go!
    class BCrypt
      class << self
        attr_writer :cost, :pepper_key
        # This is the :cost option for the BCrypt library.
        # The higher the cost the more secure it is and the longer is take the generate a hash. By default this is 10.
        # Set this to whatever you want, play around with it to get that perfect balance between
        # security and performance.
        def cost
          @cost ||= 10
        end
        alias :stretches= :cost=

        # devise has a strategy for storing a pepper - a code defined string
        # that acts as a salt, but it isn't per user. The idea behind this is
        # if a db gets stolen, it is possible the code would not be disclosed,
        # offering a weak second level of security.
        def pepper
          @pepper_key || nil
        end

        # BCrypt self-salts
        def requires_salt?
          false
        end

        # Creates a BCrypt hash for the password passed.
        def encrypt(*tokens)
          ::BCrypt::Password.create(join_tokens(tokens), :cost => cost)
        end

        # Creates a hashed secret given a salt
        def hash_secret(salt, *tokens)
          ::BCrypt::Engine.hash_secret(join_tokens(tokens), salt, cost)
        end

        # Does the hash match the tokens? Uses the same tokens that were used to encrypt.
        def matches?(hash, *tokens)
          hash = new_from_hash(hash)

          #return if the hash is nil or empty to save time
          return false if hash.nil? || hash == {}

          tokens = tokens.first # we no longer use the salt from the tokens
          test = hash_secret(hash.salt, tokens)
          secure_compare(hash, test)
        end

        # This method is used as a flag to tell Sorcery to "resave" the password
        # upon a successful login, using the new cost
        def cost_matches?(hash)
          hash = new_from_hash(hash)
          if hash.nil? || hash == {}
            false
          else
            hash.cost == cost
          end
        end

        def reset!
          @cost = 10
        end

        private

        def join_tokens(tokens)
          tokens << pepper
          tokens.flatten.join
        end

        def new_from_hash(hash)
          begin
            ::BCrypt::Password.new(hash)
          rescue ::BCrypt::Errors::InvalidHash
            return nil
          end
        end

        # constant-time comparison algorithm to prevent timing attacks,
        # taken from devise at:
        # https://github.com/plataformatec/devise/blob/d448e7d841d578045d8d5bf2a1184119ce77a359/lib/devise.rb#L428
        def secure_compare(a, b)
          # ensure both are strings
          a = a.to_s
          b = b.to_s
          # quick return if we can't run the compare
          return false if a.empty? || b.empty? || a.bytesize != b.bytesize

          # then perform constant time comparison
          l = a.unpack "C#{a.bytesize}"

          res = 0
          b.each_byte { |byte| res |= byte ^ l.shift }
          res == 0
        end
      end
    end
  end
end
