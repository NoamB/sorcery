require 'oauth'

module Sorcery
  module Protocols
    module Oauth

      def oauth_version
        '1.0'
      end

      def get_request_token(token=nil,secret=nil)
        return ::OAuth::RequestToken.new(get_consumer, token, secret) if token && secret
        get_consumer.get_request_token(oauth_callback: @callback_url)
      end

      def authorize_url(args)
        get_request_token(
          args[:request_token],
          args[:request_token_secret]
        ).authorize_url({
          oauth_callback: @callback_url
        })
      end

      def get_access_token(args)
        get_request_token(
          args[:request_token],
          args[:request_token_secret]
        ).get_access_token({
          oauth_verifier: args[:oauth_verifier]
        })
      end

      protected

      def get_consumer
        ::OAuth::Consumer.new(@key, @secret, site: @site)
      end

    end
  end
end
