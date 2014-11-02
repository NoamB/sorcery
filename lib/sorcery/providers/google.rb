module Sorcery
  module Providers
    # This class adds support for OAuth with google.com.
    #
    #   config.google.key = <key>
    #   config.google.secret = <secret>
    #   ...
    #
    class Google < Base

      include Protocols::Oauth2

      attr_accessor :scope, :token_url, :user_info_url

      def initialize
        super

        @site          = 'https://accounts.google.com'
        @auth_url      = '/o/oauth2/auth'
        @user_info_url = 'https://www.googleapis.com/oauth2/v1/userinfo'
        @scope         = 'https://www.googleapis.com/auth/userinfo.email https://www.googleapis.com/auth/userinfo.profile'
        @token_params = {
            token_method: :post,
            token_url: '/o/oauth2/token'
        }
      end

    end
  end
end
