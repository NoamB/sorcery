module Sorcery
  module Controller
    module Submodules
      module External
        module Providers
          # This module adds support for OAuth with github.com.
          # When included in the 'config.providers' option, it adds a new option, 'config.github'.
          # Via this new option you can configure Github specific settings like your app's key and secret.
          #
          #   config.github.key = <key>
          #   config.github.secret = <secret>
          #   ...
          #
          module Github
            def self.included(base)
              base.module_eval do
                class << self
                  attr_reader :github                           # access to github_client.

                  def merge_github_defaults!
                    @defaults.merge!(:@github => GithubClient)
                  end
                end
                merge_github_defaults!
                update!
              end
            end

            module GithubClient
              include Base::BaseClient
              class << self
                attr_accessor :key,
                              :secret,
                              :callback_url,
                              :auth_path,
                              :token_path,
                              :site,
                              :scope,
                              :user_info_path,
                              :user_info_mapping,
                              :state
                attr_reader   :access_token

                include Protocols::Oauth2

                def init
                  @site           = "https://github.com/"
                  @user_info_path = "https://api.github.com/user"
                  @scope          = nil
                  @auth_path      = "/login/oauth/authorize"
                  @token_path     = "/login/oauth/access_token"
                  @user_info_mapping = {}
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
