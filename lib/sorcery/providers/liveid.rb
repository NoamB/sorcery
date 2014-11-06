module Sorcery
  module Providers
    # This class adds support for OAuth with microsoft liveid.
    #
    #   config.liveid.key = <key>
    #   config.liveid.secret = <secret>
    #   ...
    #
    class Liveid < Base

      include Protocols::Oauth2

      attr_accessor :auth_url, :token_path, :user_info_url, :scope

      def initialize
        super

        @site           = 'https://oauth.live.com/'
        @auth_url       = '/authorize'
        @token_path     = '/token'
        @user_info_url  = 'https://apis.live.net/v5.0/me'
        @scope          = 'wl.basic wl.emails wl.offline_access'
      end

      def get_user_hash(access_token)
        access_token.token_param = 'access_token'
        response = access_token.get(user_info_url)

        auth_hash(access_token).tap do |h|
          h[:user_info] = JSON.parse(response.body)
          h[:uid] = h[:user_info]['id']
        end
      end

      # calculates and returns the url to which the user should be redirected,
      # to get authenticated at the external provider's site.
      def login_url(params, session)
        self.authorize_url({ authorize_url: auth_url })
      end

      # tries to login the user from access token
      def process_callback(params, session)
        args = {}.tap do |a|
          a[:code] = params[:code] if params[:code]
        end

        get_access_token(args, access_token_path: token_path,
          access_token_method: :post)
      end

    end
  end
end
