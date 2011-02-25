module Sorcery
  module Controller
    module Submodules
      module Oauth
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
