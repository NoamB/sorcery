module Sorcery
  module Providers
    # This class adds support for OAuth with github.com.
    #
    #   config.slack.key = <key>
    #   config.slack.secret = <secret>
    #   ...
    #
    class Slack < Base

      include Protocols::Oauth2

      attr_accessor :auth_path, :scope, :token_url, :user_info_path

      def initialize
        super

        @scope          = nil
        @site           = 'https://slack.com/'
        @user_info_path = 'https://api.github.com/user'
        @auth_path      = '/oauth/authorize'
        @token_url      = '/api/oauth.access'
      end

      def get_user_hash(access_token)
        response = access_token.get(user_info_path)

        auth_hash(access_token).tap do |h|
          h[:user_info] = JSON.parse(response.body).tap do |uih|
            uih['email'] = primary_email(access_token) if scope =~ /user/
          end
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

      def primary_email(access_token)
        response = access_token.get(user_info_path + "/emails")
        emails = JSON.parse(response.body)
        primary = emails.find{|i| i['primary'] }
        primary && primary['email'] || emails.first && emails.first['email']
      end

    end
  end
end
