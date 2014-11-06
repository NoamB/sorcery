module Sorcery
  module Providers
    # This class adds support for OAuth with facebook.com.
    #
    #   config.facebook.key = <key>
    #   config.facebook.secret = <secret>
    #   ...
    #
    class Facebook < Base

      include Protocols::Oauth2

      attr_reader   :mode, :param_name, :parse
      attr_accessor :access_permissions, :display, :scope, :token_url,
                    :user_info_path

      def initialize
        super

        @site           = 'https://graph.facebook.com'
        @user_info_path = '/me'
        @scope          = 'email,offline_access'
        @display        = 'page'
        @token_url      = 'oauth/access_token'
        @mode           = :query
        @parse          = :query
        @param_name     = 'access_token'
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
        authorize_url
      end

      # overrides oauth2#authorize_url to allow customized scope.
      def authorize_url
        @scope = access_permissions.present? ? access_permissions.join(',') : scope
        super
      end

      # tries to login the user from access token
      def process_callback(params, session)
        args = {}.tap do |a|
          a[:code] = params[:code] if params[:code]
        end

        get_access_token(args, token_url: token_url, mode: mode,
          param_name: param_name, parse: parse)
      end

    end
  end
end
