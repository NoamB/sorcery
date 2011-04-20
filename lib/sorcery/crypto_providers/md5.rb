require "digest/md5"
 
module Sorcery
  module CryptoProviders
    # This class was made for the users transitioning from md5 based systems. 
    # I highly discourage using this crypto provider as it superbly inferior 
    # to your other options.
    #
    # Please use any other provider offered by Sorcery.
    class MD5
      include Common
      class << self
        def secure_digest(digest)
          Digest::MD5.hexdigest(digest)
        end
      end
    end
  end
end