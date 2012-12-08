module Sorcery
  module Controller
    module Submodules
      module External
        module Providers
          # This module adds support for OAuth with vkontakte.com.
          # When included in the 'config.providers' option, it adds a new option, 'config.vkontakte'.
          # Via this new option you can configure Vkontakte specific settings like your app's key and secret.
          #
          #   config.vkontakte.key = <key>
          #   config.vkontakte.secret = <secret>
          #   ...
          #
          module Vkontakte
            def self.included(base)
              base.module_eval do
                class << self
                  attr_reader :vkontakte                           # access to vkontakte_client.

                  def merge_vkontakte_defaults!
                    @defaults.merge!(:@vkontakte => VkontakteClient)
                  end
                end
                merge_vkontakte_defaults!
                update!
              end
            end

            module VkontakteClient
              class << self
                attr_accessor :key,
                              :secret,
                              :callback_url,
                              :auth_path,
                              :token_path,
                              :site,
                              :scope,
                              :user_info_path,
                              :user_info_mapping
                attr_reader   :access_token

                include Protocols::Oauth2

                def init
                  @site           = "https://oauth.vk.com/"
                  @user_info_url = "https://api.vk.com/method/getUserInfo"
                  @scope          = nil
                  @auth_path      = "/authorize"
                  @token_path     = "/access_token"
                  @user_info_mapping = {}
                end

                def get_user_hash
                  user_hash = {}
                  response = @access_token.get("#{@user_info_url}?access_token=#{@access_token.token}")
                  user_hash[:user_info] = JSON.parse(response.body)
                  if user_hash[:user_info]
                    user_hash[:user_info] = user_hash[:user_info]["response"]
                  end
                  user_hash[:uid] = user_hash[:user_info]['user_id']
                  user_hash
                end

                def has_callback?
                  true
                end

                # calculates and returns the url to which the user should be redirected,
                # to get authenticated at the external provider's site.
                def login_url(params,session)
                  self.authorize_url({:authorize_url => @auth_path})
                end

                # tries to login the user from access token
                def process_callback(params,session)
                  args = {}
                  args.merge!({:code => params[:code]}) if params[:code]
                  options = {
                    :token_url    => @token_path,
                    :token_method => :post
                  }
                  @access_token = self.get_access_token(args, options)
                end

              end
              init
            end

          end
        end
      end
    end
  end
end
