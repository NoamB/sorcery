module Sorcery
  module Controller
    module Submodules
      # This submodule helps you login users from OAuth providers such as Twitter.
      module Oauth
        def self.included(base)
          Config.module_eval do
            class << self
              attr_reader :oauth_providers                           # oauth providers like twitter.
                            
              def merge_oauth_defaults!
                @defaults.merge!(:@oauth_providers => [])
              end
              
              def oauth_providers=(providers)
                providers.each do |provider|
                  begin # FIXME: is this protection needed?
                    include Oauth.const_get(provider.to_s.split("_").map {|p| p.capitalize}.join(""))
                  rescue NameError
                    # don't stop on a missing provider.
                  end
                end
              end
            end
            merge_oauth_defaults!
          end
        end

      end
    end
  end
end
