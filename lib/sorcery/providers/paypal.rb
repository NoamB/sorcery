module Sorcery
  module Providers
    # This class adds support for OAuth with paypal.com.
    #
    #   config.paypal.key = <key>
    #   config.paypal.secret = <secret>
    #   ...
    #
    class Paypal < Base

      include Protocols::Oauth2

      attr_accessor :auth_url, :scope, :token_url, :user_info_url

      def initialize
        super

        @scope           = 'openid email'
        @site            = 'https://api.paypal.com'
        @auth_url        = 'https://www.paypal.com/webapps/auth/protocol/openidconnect/v1/authorize'
        @user_info_url   = 'https://api.paypal.com/v1/identity/openidconnect/userinfo?schema=openid'
        @token_url       = 'https://api.paypal.com/v1/identity/openidconnect/tokenservice'
        @state           = SecureRandom.hex(16)
      end

      def get_user_hash(access_token)
        response = access_token.get(user_info_url)
        body = JSON.parse(response.body)
        auth_hash(access_token).tap do |h|
          h[:user_info] = body
          h[:uid] = body['user_id']
          h[:email] = body['email']
        end
      end

      def get_access_token(args, options = {})
        client = build_client(options)
        client.auth_code.get_token(
          args[:code],
          {
            redirect_uri: @callback_url,
            parse: options.delete(:parse)
          },
          options
        )
      end

      def login_url(params, session)
        authorize_url({ authorize_url: auth_url })
      end

      def process_callback(params, session)
        args = {}.tap do |a|
          a[:code] = params[:code] if params[:code]
        end

        get_access_token(args, token_url: token_url, token_method: :post)
      end

    end
  end
end
