require 'oauth2'

module Sorcery
  module Protocols
    module Oauth2

      attr_accessor :user_info_url, :auth_url, :auth_params, :token_params

      def oauth_version
        '2.0'
      end

      def authorize_url(options = {})
        client = build_client(options)
        client.auth_code.authorize_url(
          redirect_uri: @callback_url,
          scope: @scope,
          display: @display,
          state: @state
        )
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

      def build_client(options = {})
        defaults = {
          site: @site,
          ssl: { ca_file: Sorcery::Controller::Config.ca_file }
        }
        ::OAuth2::Client.new(
          @key,
          @secret,
          defaults.merge!(options)
        )
      end

      # calculates and returns the url to which the user should be redirected,
      # to get authenticated at the external provider's site.
      def login_url(params, session)
        self.authorize_url({ authorize_url: auth_url })
      end


      def get_user_hash(access_token)
        response = access_token.get(user_info_url)

        {}.tap do |h|
          h[:user_info] = JSON.parse(response.body)
          h[:uid] = h[:user_info]['id']
        end
      end

      # tries to login the user from access token
      def process_callback(params, session)
        args = {}.tap do |a|
          a[:code] = params[:code] if params[:code]
        end

        get_access_token(args, options: token_params)
      end

    end
  end
end
