module Sorcery
  module Controller
    module Submodules
      module External
        module Providers
          # This module adds support for OAuth with vk.com.
          # When included in the 'config.providers' option, it adds a new option, 'config.vk'.
          # Via this new option you can configure Vk specific settings like your app's key and secret.
          #
          #   config.vk.key = <key>
          #   config.vk.secret = <secret>
          #   ...
          #
          module Vk
            def self.included(base)
              base.module_eval do
                class << self
                  attr_reader :vk                           # access to vk_client.

                  def merge_vk_defaults!
                    @defaults.merge!(:@vk => VkClient)
                  end
                end
                merge_vk_defaults!
                update!
              end
            end

            module VkClient
              include Base::BaseClient
              class << self
                attr_accessor :key,
                              :secret,
                              :callback_url,
                              :auth_path,
                              :token_path,
                              :site,
                              :user_info_mapping,
                              :state
                attr_reader   :access_token

                include Protocols::Oauth2

                def init
                  @site           = "https://oauth.vk.com/"
                  @user_info_url  = "https://api.vk.com/method/getProfiles"
                  @auth_path      = "/authorize"
                  @token_path     = "/access_token"
                  @user_info_mapping = {}
                end

                def get_user_hash(access_token)
                  user_hash = {}

                  params = {
                    :access_token => access_token.token,
                    :uids         => access_token.params["user_id"],
                    :fields       => @user_info_mapping.values.join(",")
                  }

                  response = access_token.get(@user_info_url, :params => params)
                  if user_hash[:user_info] = JSON.parse(response.body)
                    user_hash[:user_info] = user_hash[:user_info]["response"][0]
                    # add full_name - useful if you do not store it in separate fields
                    user_hash[:user_info]["full_name"] = [user_hash[:user_info]["first_name"], user_hash[:user_info]["last_name"]].join(" ")
                    user_hash[:uid] = user_hash[:user_info]["uid"]
                  end
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
                  return self.get_access_token(args, options)
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
