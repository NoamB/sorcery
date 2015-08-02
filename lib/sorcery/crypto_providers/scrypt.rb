require 'scrypt'

module Sorcery
  module CryptoProviders
    # For more information on why using scrypt is a good idea:
    #   https://github.com/pbhogan/scrypt
    #
    # The scrypt key derivation function is designed to be far more secure against hardware
    # brute-force attacks than alternative functions such as PBKDF2 or bcrypt.
    #
    # Decided SCrypt is for you? Just insall the scrypt gem:
    #
    #   gem install scrypt
    #
    # Update your initializer to use it:
    #
    #   config.encryption_algorithm = :scrypt
    #
    # You are good to go!
    class SCrypt
      class << self

        # The designers of scrypt estimate that on modern (2009) hardware, if 5 seconds are spent computing a derived key,
        # the cost of a hardware brute-force attack against scrypt is roughly 4000 times greater than the cost of a
        # similar attack against bcrypt (to find the same password), and 20000 times greater than a similar attack against PBKDF2.
        #
        # Default options will result in calculation time of approx. 200 ms with 1 MB memory use.
        #
        # SCrypt has five options that can be configured.  The defaults are below and can be altered
        # Please review the SCript documentation for further information

        # specifies the length in bytes of the key you want to generate.
        # The default is 32 bytes (256 bits).
        # Minimum is 16 bytes (128 bits).
        # Maximum is 512 bytes (4096 bits).
        def key_len
          @key_len ||= 32
        end
        attr_writer :key_len

        # specifies the size in bytes of the random salt you want to generate.
        # The default and minimum is 8 bytes (64 bits). Maximum is 32 bytes (256 bits).
        def salt_size
          @salt_size ||= 8
        end
        attr_writer :salt_size

        # specifies the maximum number of seconds the computation should take.
        def max_time
          @max_time ||= 0.2
        end
        attr_writer :max_time

        # specifies the maximum number of bytes the computation should take.
        # A value of 0 specifies no upper limit. The minimum is always 1 MB.
        def max_mem
          @max_mem ||= 1024 * 1024
        end
        attr_writer :max_mem

        # specifies the maximum memory in a fraction of available resources to use.
        # Any value equal to 0 or greater than 0.5 will result in 0.5 being used.
        def max_memfrac
          @max_memfrac ||= 0.5
        end
        attr_writer :max_memfrac

        # Hashes a secret, returning a SCrypt::Password instance.
        def encrypt( *tokens )
          ::SCrypt::Password.create( join_tokens( tokens ), { key_len:     key_len,
                                                              salt_size:   salt_size,
                                                              max_time:    max_time,
                                                              max_mem:     max_mem,
                                                              max_memfrac: max_memfrac } )
        end

        # Compares a potential secret against the hash. Returns true if the secret is the original secret, false otherwise.
        def matches?( crypted, *tokens )
          crypted == join_tokens( tokens )
        end

        def reset!
          @key_len     = 32
          @salt_size   = 8
          @max_time    = 0.2
          @max_mem     = 1024 * 1024
          @max_memfrac = 0.5
        end

        private

        def join_tokens( tokens )
          tokens.flatten.join
        end

      end
    end
  end
end