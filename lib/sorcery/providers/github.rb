module Sorcery
  module Providers
    # This class adds support for OAuth with github.com.
    #
    #   config.github.key = <key>
    #   config.github.secret = <secret>
    #   ...
    #
    class Github < Base

      include Protocols::Oauth2

      attr_accessor :auth_path, :scope, :token_url, :user_info_path

      def initialize
        super

        @scope          = nil
        @site           = 'https://github.com/'
        @user_info_path = 'https://api.github.com/user'
        @auth_path      = '/login/oauth/authorize'
        @token_url      = '/login/oauth/access_token'
      end

      def get_user_hash(access_token)
        response = access_token.get(user_info_path)

        auth_hash(access_token).tap do |h|
          h[:user_info] = JSON.parse(response.body)
          h[:uid] = h[:user_info]['id']
        end
      end

      # calculates and returns the url to which the user should be redirected,
      # to get authenticated at the external provider's site.
      def login_url(params, session)
        authorize_url({ authorize_url: auth_path })
      end

      # tries to login the user from access token
      def process_callback(params, session)
        args = {}.tap do |a|
          a[:code] = params[:code] if params[:code]
        end

        get_access_token(args, token_url: token_url, token_method: :post)
      end

    end
  end
end
