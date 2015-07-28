module Sorcery
  module Providers
    # This class adds support for OAuth with yahoo.co.jp.
    #
    #   config.yahoojp.key = <key>
    #   config.yahoojp.secret = <secret>
    #   ...
    #
    class Yahoojp < Base

      include Protocols::Oauth2

      attr_accessor :auth_path, :token_path, :user_info_url, :scope

      def initialize
        super

        @site          = 'https://auth.login.yahoo.co.jp'
        @auth_path     = '/yconnect/v1/authorization'
        @token_path    = '/yconnect/v1/token'
        @user_info_url = 'https://userinfo.yahooapis.jp/yconnect/v1/attribute?schema=openid'
        @scope         = 'openid'
      end

      def get_user_hash(access_token)
        response = access_token.get(user_info_url)

        auth_hash(access_token).tap do |h|
          h[:user_info] = JSON.parse(response.body)
          h[:uid] = h[:user_info]['user_id']
        end
      end

      # calculates and returns the url to which the user should be redirected,
      # to get authenticated at the external provider's site.
      def login_url(params, session)
        authorize_url(authorize_url: auth_path)
      end

      # tries to login the user from access token
      def process_callback(params, session)
        args = {}.tap do |a|
          a[:code] = params[:code] if params[:code]
        end

        basic_auth = Base64.encode64("#{key}:#{secret}").gsub("\n", '')
        headers = { 'Authorization' => "Basic #{basic_auth}" }
        get_access_token(args, token_url: token_path, token_method: :post, headers: headers)
      end

      def build_client(options = {})
        if options[:headers] && options[:headers]['Authorization']
          # OAuth2::Client does not support the HTTP Basic authentication.
          # https://github.com/intridea/oauth2/pull/192
          # http://tools.ietf.org/html/rfc6749#section-2.3.1
          defaults = {
            site: @site,
            ssl: { ca_file: Sorcery::Controller::Config.ca_file }
          }
          ::OAuth2::Client.new(nil, nil, defaults.merge!(options))
        else
          super
        end
      end

    end
  end
end
