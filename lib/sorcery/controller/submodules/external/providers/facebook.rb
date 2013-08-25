module Sorcery
  module Controller
    module Submodules
      module External
        module Providers
          # This module adds support for OAuth with facebook.com.
          # When included in the 'config.providers' option, it adds a new option, 'config.facebook'.
          # Via this new option you can configure Facebook specific settings like your app's key and secret.
          #
          #   config.facebook.key = <key>
          #   config.facebook.secret = <secret>
          #   ...
          #
          module Facebook
            def self.included(base)
              base.module_eval do
                class << self
                  attr_reader :facebook                           # access to facebook_client.

                  def merge_facebook_defaults!
                    @defaults.merge!(:@facebook => FacebookClient)
                  end
                end
                merge_facebook_defaults!
                update!
              end
            end

            module FacebookClient
              include Base::BaseClient
              class << self
                attr_accessor :key,
                              :secret,
                              :callback_url,
                              :site,
                              :user_info_path,
                              :scope,
                              :user_info_mapping,
                              :display,
                              :access_permissions,
                              :state
                attr_reader   :access_token

                include Protocols::Oauth2

                def init
                  @site           = "https://graph.facebook.com"
                  @user_info_path = "/me"
                  @scope          = "email,offline_access"
                  @user_info_mapping = {}
                  @display        = "page"
                  @token_url      = "oauth/access_token"
                  @mode           = :query
                  @parse          = :query
                  @param_name     = "access_token"
                end

                def get_user_hash(access_token)
                  user_hash = {}
                  response = access_token.get(@user_info_path)
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
                  self.authorize_url
                end

                # overrides oauth2#authorize_url to allow customized scope.
                def authorize_url
                  @scope = self.access_permissions.present? ? self.access_permissions.join(",") : @scope
                  super
                end

                # tries to login the user from access token
                def process_callback(params,session)
                  args = {}
                  options = { :token_url => @token_url, :mode => @mode, :param_name => @param_name, :parse => @parse }
                  args.merge!({:code => params[:code]}) if params[:code]
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
