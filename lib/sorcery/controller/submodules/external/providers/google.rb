module Sorcery
  module Controller
    module Submodules
      module External
        module Providers
          # This module adds support for OAuth with google.com.
          # When included in the 'config.providers' option, it adds a new option, 'config.google'.
          # Via this new option you can configure Google specific settings like your app's key and secret.
          #
          #   config.google.key = <key>
          #   config.google.secret = <secret>
          #   ...
          #
          module Google
            def self.included(base)
              base.module_eval do
                class << self
                  attr_reader :google                           # access to google_client.

                  def merge_google_defaults!
                    @defaults.merge!(:@google => GoogleClient)
                  end
                end
                merge_google_defaults!
                update!
              end
            end

            module GoogleClient
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
                  @site              = "https://accounts.google.com"
                  @auth_url          = "/o/oauth2/auth"
                  @token_url         = "/o/oauth2/token"
                  @user_info_url     = "https://www.googleapis.com/oauth2/v1/userinfo"
                  @scope             = "https://www.googleapis.com/auth/userinfo.email https://www.googleapis.com/auth/userinfo.profile"
                  @user_info_mapping = {}
                end

                def get_user_hash(access_token)
                  user_hash = {}
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
                    :token_url => @token_url,
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
