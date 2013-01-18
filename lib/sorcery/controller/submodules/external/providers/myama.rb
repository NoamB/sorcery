module Sorcery
  module Controller
    module Submodules
      module External
        module Providers
          # This module adds support for OAuth with myama.com.
          # When included in the 'config.providers' option, it adds a new option, 'config.myama'.
          # Via this new option you can configure Myama specific settings like your app's key and secret.
          #
          #   config.myama.key = <key>
          #   config.myama.secret = <secret>
          #   ...
          #
          module Myama
            def self.included(base)
              base.module_eval do
                class << self
                  attr_reader :myama                           # access to myama_client.

                  def merge_myama_defaults!
                    @defaults.merge!(:@myama => MyamaClient)
                  end
                end
                merge_myama_defaults!
                update!
              end
            end

            module MyamaClient
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
                  @site           = ENV["MYAMA_SITE"]
                  @user_info_path = ENV["MYAMA_USER_INFO_PATH"]
                  @scope          = nil
                  @auth_path      = "/oauth/authorize"
                  @token_path     = "/oauth/token"
                  @user_info_mapping = {}
                end

                def get_user_hash
                  user_hash = {}
                  response = @access_token.get(@user_info_path)
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
