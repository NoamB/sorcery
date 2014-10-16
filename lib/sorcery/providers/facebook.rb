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
      attr_accessor :access_permissions, :display, :scope

      def initialize
        super

        @site           = 'https://graph.facebook.com'
        @user_info_url = '/me'
        @scope          = 'email,offline_access'
        @display        = 'page'
        @token_params   = {
            token_url: 'oauth/access_token',
            mode: :query,
            parse: :query,
            param_name: 'access_token'
        }
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

    end
  end
end
