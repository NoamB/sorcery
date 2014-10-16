module Sorcery
  module Providers
    # This class adds support for OAuth with microsoft liveid.
    #
    #   config.liveid.key = <key>
    #   config.liveid.secret = <secret>
    #   ...
    #
    class Liveid < Base

      include Protocols::Oauth2

      attr_accessor :auth_url, :token_path, :user_info_url, :scope

      def initialize
        super

        @site           = 'https://oauth.live.com/'
        @auth_url       = '/authorize'
        @user_info_url  = 'https://apis.live.net/v5.0/me'
        @scope          = 'wl.basic wl.emails wl.offline_access'
        @token_params = {
            access_token_path: '/token',
            access_token_method: :post,
            token_param: 'access_token'
        }
      end
    end
  end
end
