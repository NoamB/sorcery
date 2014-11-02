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

      attr_accessor :user_info_url, :scope

      def initialize
        super

        @site           = 'https://oauth.vk.com/'
        @user_info_url  = 'https://api.vk.com/method/getProfiles'
        @auth_url      = '/authorize'
        @token_url     = '/access_token'
        @scope          = 'email'
      end

      def get_user_hash(access_token)
        user_hash = {}

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

    end
  end
end
