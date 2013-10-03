module Sorcery
  module Controller
    module Submodules
      module External
        module Providers
          # This module adds support for OAuth with gatekeeper.com.
          # When included in the 'config.providers' option, it adds a new option, 'config.gatekeeper'.
          # Via this new option you can configure Gatekeeper specific settings like your app's key and secret.
          #
          #   config.gatekeeper.key = <key>
          #   config.gatekeeper.secret = <secret>
          #   ...
          #
          module Gatekeeper
            def self.included(base)
              base.module_eval do
                class << self
                  attr_reader :gatekeeper                           # access to gatekeeper_client.

                  def merge_gatekeeper_defaults!
                    @defaults.merge!(:@gatekeeper => GatekeeperClient)
                  end
                end
                merge_gatekeeper_defaults!
                update!
              end
            end

            module GatekeeperClient
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
                  @site           = ENV["GATEKEEPER_SITE"]
                  @user_info_path = ENV["GATEKEEPER_USER_INFO_PATH"]
                  @scope          = nil
                  @auth_path      = "/oauth/authorize"
                  @token_path     = "/oauth/token"
                  @user_info_mapping = {}
                end

                def get_user_hash
                  user_hash = {}
                  response = @access_token.get(@user_info_path)
                  user_info = JSON.parse(response.body)
                  user_hash[:user_info] = user_info['user']
                  user_hash[:uid] = user_hash[:user_info]['id']
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