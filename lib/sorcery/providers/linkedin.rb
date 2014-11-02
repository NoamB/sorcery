module Sorcery
  module Providers
    # This class adds support for OAuth with Linkedin.com.
    #
    #   config.linkedin.key = <key>
    #   config.linkedin.secret = <secret>
    #   ...
    #
    class Linkedin < Base

      include Protocols::Oauth

      attr_accessor :authorize_path, :access_permissions, :access_token_path,
                    :request_token_path, :user_info_fields, :user_info_path

      def initialize
        @configuration = {
          site: 'https://api.linkedin.com',
          authorize_path: '/uas/oauth/authenticate',
          request_token_path: '/uas/oauth/requestToken',
          access_token_path: '/uas/oauth/accessToken'
        }
        @user_info_path = '/v1/people/~'
      end

      # Override included get_consumer method to provide authorize_path
      def get_consumer
        # Add access permissions to request token path
        @configuration[:request_token_path] += '?scope=' + access_permissions.join('+') unless access_permissions.blank? or @configuration[:request_token_path].include? '?scope='
        ::OAuth::Consumer.new(@key, @secret, @configuration)
      end

      def get_user_hash(access_token)
        fields = self.user_info_fields.join(',')
        response = access_token.get("#{@user_info_path}:(#{fields})", 'x-li-format' => 'json')

        auth_hash(access_token).tap do |h|
          h[:user_info] = JSON.parse(response.body)
          h[:uid] = h[:user_info]['id'].to_s
        end
      end

      # calculates and returns the url to which the user should be redirected,
      # to get authenticated at the external provider's site.
      def login_url(params, session)
        req_token = get_request_token
        session[:request_token]         = req_token.token
        session[:request_token_secret]  = req_token.secret
        authorize_url({ request_token: req_token.token, request_token_secret: req_token.secret })
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
