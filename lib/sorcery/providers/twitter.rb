module Sorcery
  module Providers
    # This class adds support for OAuth with Twitter.com.
    #
    #   config.twitter.key = <key>
    #   config.twitter.secret = <secret>
    #   ...
    #
    class Twitter < Base

      include Protocols::Oauth

      attr_accessor :state, :user_info_path

      def initialize
        super

        @site           = 'https://api.twitter.com'
        @user_info_path = '/1.1/account/verify_credentials.json'
      end

      # Override included get_consumer method to provide authorize_path
      def get_consumer
        ::OAuth::Consumer.new(@key, secret, site: site, authorize_path: '/oauth/authenticate')
      end

    end
  end
end
