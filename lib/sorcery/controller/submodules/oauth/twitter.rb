module Sorcery
  module Controller
    module Submodules
      module Oauth
        # This module adds support for OAuth with Twitter.com.
        # When included in the 'config.providers' option, it adds a new option, 'config.twitter'.
        # Via this new option you can configure Twitter specific settings like your app's key and secret.
        #
        #   config.twitter.key = <key>
        #   config.twitter.secret = <secret>
        #   ...
        #
        module Twitter
          def self.included(base)
            base.module_eval do
              class << self
                attr_reader :twitter                           # access to twitter_config.

                def merge_twitter_defaults!
                  @defaults.merge!(:@twitter => TwitterConfig)
                end
              end
              merge_twitter_defaults!
              update!
            end
          end

          module TwitterConfig
            class << self              
              attr_accessor :key,
                            :secret,
                            :callback_url
              
              def oauth_version
                "1.0a"
              end
            
              def site
                "https://api.twitter.com"
              end
              
              def user_info_path
                "/1/account/verify_credentials.json"
              end

            end
            
          end
          
        end
      end
    end
  end
end
