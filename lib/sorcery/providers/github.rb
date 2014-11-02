module Sorcery
  module Providers
    # This class adds support for OAuth with github.com.
    #
    #   config.github.key = <key>
    #   config.github.secret = <secret>
    #   ...
    #
    class Github < Base

      include Protocols::Oauth2

      attr_accessor :scope

      def initialize
        super

        @scope          = nil
        @site           = 'https://github.com/'
        @user_info_url = 'https://api.github.com/user'
        @auth_url      = '/login/oauth/authorize'
        @token_params = {
            token_method: :post,
            token_url: '/login/oauth/access_token'
        }
      end

    end
  end
end
