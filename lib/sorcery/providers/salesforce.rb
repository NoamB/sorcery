module Sorcery
  module Providers
    # This class adds support for OAuth with salseforce.com.
    #
    #   config.salseforce.key = <key>
    #   config.salseforce.secret = <secret>
    #   ...
    #
    class Salesforce < Base

      include Protocols::Oauth2

      attr_accessor :auth_url, :token_url, :user_info_url

      def initialize
        super

        @site          = 'https://login.salesforce.com'
        @auth_url      = '/services/oauth2/authorize'
        @token_url     = '/services/oauth2/token'
      end

      def get_user_hash(access_token)
        response = access_token.get(user_info_url)

        auth_hash(access_token).tap do |h|
          h[:user_info] = JSON.parse(response.body)
          h[:uid] = h[:user_info]['id']
        end
      end

      # calculates and returns the url to which the user should be redirected,
      # to get authenticated at the external provider's site.
      def login_url(params, session)
        authorize_url({ authorize_url: auth_url })
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
