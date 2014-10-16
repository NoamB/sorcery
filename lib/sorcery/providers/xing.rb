module Sorcery
  module Providers
    # This class adds support for OAuth with xing.com.
    #
    #   config.xing.key = <key>
    #   config.xing.secret = <secret>
    #   ...
    #
    class Xing < Base

      include Protocols::Oauth

      attr_accessor :access_token_path, :authorize_path, :request_token_path, :user_info_path


      def initialize
        @configuration = {
            site: 'https://api.xing.com/v1',
            authorize_path: '/authorize',
            request_token_path: '/request_token',
            access_token_path: '/access_token'
        }
        @user_info_path = '/users/me'
      end

      # Override included get_consumer method to provide authorize_path
      def get_consumer
        ::OAuth::Consumer.new(@key, @secret, @configuration)
      end

    end
  end
end
