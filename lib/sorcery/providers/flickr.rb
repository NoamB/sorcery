module Sorcery
  module Providers
    # This class adds support for OAuth with Twitter.com.
    #
    #   config.flickr.key = <key>
    #   config.flickr.secret = <secret>
    #   ...
    #
    class Flickr < Base
      include Protocols::Oauth

      attr_accessor :user_info_path

      def initialize
        @configuration = {
          site: 'https://api.flickr.com',
          authorize_path: '/services/oauth/authorize',
          request_token_path: '/services/oauth/request_token',
          access_token_path: '/services/oauth/access_token'
        }

        @user_info_path = '/services/rest/?method=flickr.urls.getUserProfile&format=json&nojsoncallback=1'
      end

      # Override included get_consumer method to provide authorize_path
      def get_consumer
        ::OAuth::Consumer.new(@key, @secret, @configuration)
      end

      def get_user_hash(access_token)
        response = access_token.get(user_info_path)

        auth_hash(access_token).tap do |h|
          h[:user_info] = JSON.parse(response.body)
          h[:uid] = h[:user_info]['user']['nsid'].to_s
        end
      end

      # override method to provide additional necessary parameters
      def authorize_url(args)
        get_request_token(args[:request_token], args[:request_token_secret])
          .authorize_url(perms: 'read')
      end

      # calculates and returns the url to which the user should be redirected,
      # to get authenticated at the external provider's site.
      def login_url(_params, session)
        req_token = get_request_token
        session[:request_token]         = req_token.token
        session[:request_token_secret]  = req_token.secret
        authorize_url(request_token: req_token.token, request_token_secret: req_token.secret)
      end

      # tries to login the user from access token
      def process_callback(params, session)
        args = {
          oauth_verifier:       params[:oauth_verifier],
          request_token:        session[:request_token],
          request_token_secret: session[:request_token_secret]
        }

        get_access_token(args)
      end
    end
  end
end
