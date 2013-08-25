module Sorcery
  module Controller
    module Submodules
      module External
        module Providers
          # This module adds support for OAuth with microsoft liveid
          # When included in the 'config.providers' option, it adds a new option, 'config.liveid'.
          # Via this new option you can configure LiveId specific settings like your app's key and secret.
          #
          #   config.liveid.key = <key>
          #   config.liveid.secret = <secret>
          #   ...
          #
          module Liveid
            def self.included(base)
              base.module_eval do
                class << self
                  attr_reader :liveid                           # access to liveid_client.

                  def merge_liveid_defaults!
                    @defaults.merge!(:@liveid => LiveidClient)
                  end
                end
                merge_liveid_defaults!
                update!
              end
            end

            module LiveidClient
              include Base::BaseClient
              class << self
                attr_accessor :key,
                              :secret,
                              :callback_url,
                              :site,
                              :auth_url,
                              :token_path,
                              :user_info_url,
                              :scope,
                              :user_info_mapping,
                              :state
                attr_reader   :access_token

                include Protocols::Oauth2

                def init
                  @site              = "https://oauth.live.com/"
                  @auth_url          = "/authorize"
                  @token_path        = "/token"
                  @user_info_url     = "https://apis.live.net/v5.0/me"
                  @scope             = "wl.basic wl.emails wl.offline_access"
                  @user_info_mapping = {}
                end

                def get_user_hash(access_token)
                  user_hash = {}
                  access_token.token_param = "access_token"
                  response = access_token.get(@user_info_url)
                  user_hash[:user_info] = JSON.parse(response.body)
                  user_hash[:uid] = user_hash[:user_info]['id']
                  user_hash
                end

                def has_callback?
                  true
                end

                # calculates and returns the url to which the user should be redirected,
                # to get authenticated at the external provider's site.
                def login_url(params,session)
                  self.authorize_url({:authorize_url => @auth_url})
                end

                # tries to login the user from access token
                def process_callback(params,session)
                  args = {}
                  args.merge!({:code => params[:code]}) if params[:code]
                  options = {
                    :access_token_path => @token_path,
                    :access_token_method => :post
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
