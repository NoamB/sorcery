module Sorcery
  module Controller
    module Submodules
      module Oauth
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
                attr_reader :facebook                           # access to facebook_config.

                def merge_facebook_defaults!
                  @defaults.merge!(:@facebook => FacebookConfig)
                end
              end
              merge_facebook_defaults!
              update!
            end
          end

          module FacebookConfig
            class << self              
              attr_accessor :key,
                            :secret,
                            :callback_url
            
              def oauth_version
                "2.0"
              end
              
              def site
                "https://graph.facebook.com"
              end
              
              def user_info_path
                "/me"
              end

            end
            
          end
          
        end
      end
    end
  end
end
