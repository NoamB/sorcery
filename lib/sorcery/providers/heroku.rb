module Sorcery
  module Providers

    # This class adds support for OAuth with heroku.com.

    # config.heroku.key = <key>
    # config.heroku.secret = <secret>
    # config.heroku.callback_url = "<host>/oauth/callback?provider=heroku"
    # config.heroku.scope = "read"
    # config.heroku.user_info_mapping = {:email => "email", :name => "email" }

    # NOTE:
    # The full path must be set for OAuth Callback URL when configuring the API Client Information on Heroku.

    class Heroku < Base

      include Protocols::Oauth2

      attr_accessor :auth_path, :scope, :token_url, :user_info_path

      def initialize
        super

        @scope          = nil
        @site           = 'https://id.heroku.com'
        @user_info_path = 'https://api.heroku.com/account'
        @auth_path      = '/oauth/authorize'
        @token_url      = '/oauth/token'
        @user_info_path = '/account'
        @state          = SecureRandom.hex(16)
      end

      def get_user_hash(access_token)
        response = access_token.get(user_info_path)
        body = JSON.parse(response.body)
        auth_hash(access_token).tap do |h|
          h[:user_info] = body
          h[:uid] = body['id'].to_s
          h[:email] = body['email'].to_s
        end
      end

      def login_url(params, session)
        authorize_url({ authorize_url: auth_path })
      end

      # tries to login the user from access token
      def process_callback(params, session)
        raise "Invalid state. Potential Cross Site Forgery" if params[:state] != state
        args = { }.tap do |a|
          a[:code] = params[:code] if params[:code]
        end
        get_access_token(args, token_url: token_url, token_method: :post)
      end
    end
  end
end