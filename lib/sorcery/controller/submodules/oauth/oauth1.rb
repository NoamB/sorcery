require 'oauth'
module Sorcery
  module Controller
    module Submodules
      module Oauth
        module Oauth1
          def oauth_version
            "1.0"
          end
          
          def get_request_token
            ::OAuth::Consumer.new(@key, @secret, :site => @site).get_request_token(:oauth_callback => @callback_url)
          end
          
          def authorize_url(args)
            args[:request_token].authorize_url(:oauth_callback => @callback_url)
          end
          
          def get_access_token(args)
            args[:request_token].get_access_token(:oauth_verifier => args[:oauth_verifier])
          end
        end
      end
    end
  end
end