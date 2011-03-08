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
                    @defaults.merge!(:@facebook => FacebookClient.new)
                  end
                end
                merge_facebook_defaults!
                update!
              end
            end
          
            class FacebookClient
              attr_accessor :key,
                            :secret,
                            :callback_url,
                            :site,
                            :user_info_path
                            
              include Oauth2
            
              def initialize
                @site           = "https://graph.facebook.com"
                @user_info_path = "/me"
              end
              
              def oauth_version
                "2.0"
              end
            end
            
          end
        end    
      end
    end
  end
end
