require 'oauth'

module Sorcery
  module Protocols
    module Oauth

      def oauth_version
        '1.0'
      end

      def get_request_token(token=nil,secret=nil)
        return ::OAuth::RequestToken.new(get_consumer, token, secret) if token && secret
        get_consumer.get_request_token(oauth_callback: @callback_url)
      end

      def authorize_url(args)
        get_request_token(
          args[:request_token],
          args[:request_token_secret]
        ).authorize_url({
          oauth_callback: @callback_url
        })
      end

      # calculates and returns the url to which the user should be redirected,
      # to get authenticated at the external provider's site.
      def login_url(params, session)
        req_token = get_request_token
        session[:request_token]         = req_token.token
        session[:request_token_secret]  = req_token.secret
        authorize_url({ request_token: req_token.token, request_token_secret: req_token.secret })
      end

      def get_access_token(args)
        get_request_token(
          args[:request_token],
          args[:request_token_secret]
        ).get_access_token({
          oauth_verifier: args[:oauth_verifier]
        })
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

      def get_user_hash(access_token)
        response = access_token.get(user_info_path)

        {}.tap do |h|
          h[:user_info] = JSON.parse(response.body)
          h[:uid] = h[:user_info]['id'].to_s
        end
      end

      protected

      def get_consumer
        ::OAuth::Consumer.new(@key, @secret, site: @site)
      end

    end
  end
end
