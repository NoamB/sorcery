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

      def get_user_hash(access_token)
        response = access_token.get(user_info_path)

        auth_hash(access_token).tap do |h|
          h[:user_info] = JSON.parse(response.body)
          h[:uid] = h[:user_info]['id'].to_s
        end
      end

      # calculates and returns the url to which the user should be redirected,
      # to get authenticated at the external provider's site.
      def login_url(params, session)
        req_token = self.get_request_token
        session[:request_token]         = req_token.token
        session[:request_token_secret]  = req_token.secret
        self.authorize_url({ request_token: req_token.token, request_token_secret: req_token.secret })
      end

      # tries to login the user from access token
      def process_callback(params, session)
        args = {
          oauth_verifier:       params[:oauth_verifier],
          request_token:        session[:request_token],
          request_token_secret: session[:request_token_secret]
        }

        args.merge!({ code: params[:code] }) if params[:code]
        get_access_token(args)
      end

    end
  end
end
