module Sorcery
  module Providers
    # This class adds support for OAuth with vk.com.
    #
    #   config.vk.key = <key>
    #   config.vk.secret = <secret>
    #   ...
    #
    class Vk < Base

      include Protocols::Oauth2

      attr_accessor :auth_path, :token_path, :user_info_url, :scope

      def initialize
        super

        @site           = 'https://oauth.vk.com/'
        @user_info_url  = 'https://api.vk.com/method/getProfiles'
        @auth_path      = '/authorize'
        @token_path     = '/access_token'
        @scope          = 'email'
      end

      def get_user_hash(access_token)
        user_hash = auth_hash(access_token)

        params = {
          access_token: access_token.token,
          uids:         access_token.params['user_id'],
          fields:       user_info_mapping.values.join(','),
          scope:        scope
        }

        response = access_token.get(user_info_url, params: params)
        if user_hash[:user_info] = JSON.parse(response.body)
          user_hash[:user_info] = user_hash[:user_info]['response'][0]
          user_hash[:user_info]['full_name'] = [user_hash[:user_info]['first_name'], user_hash[:user_info]['last_name']].join(' ')

          user_hash[:uid] = user_hash[:user_info]['uid']
          user_hash[:user_info]['email'] = access_token.params['email']
        end
        user_hash
      end

      # calculates and returns the url to which the user should be redirected,
      # to get authenticated at the external provider's site.
      def login_url(params, session)
        self.authorize_url({ authorize_url: auth_path })
      end

      # tries to login the user from access token
      def process_callback(params, session)
        args = {}.tap do |a|
          a[:code] = params[:code] if params[:code]
        end

        get_access_token(args, token_url: token_path, token_method: :post)
      end

    end
  end
end
