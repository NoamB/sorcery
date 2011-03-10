module Sorcery
  module Controller
    module Submodules
      module Oauth
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
              class << self
                attr_accessor :key,
                              :secret,
                              :callback_url,
                              :site,
                              :user_info_path,
                              :scope
                            
                include Oauth2
            
                def init
                  @site           = "https://graph.facebook.com"
                  @user_info_path = "/me"
                  @scope          = "email,offline_access"
                end
                
                def get_user_hash(access_token)
                  user_hash = {}
                  response = access_token.get(@user_info_path)
                  user_hash[:user_info] = JSON.parse(response)
                  user_hash[:uid] = user_hash[:user_info]['id'].to_i
                  user_hash
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
