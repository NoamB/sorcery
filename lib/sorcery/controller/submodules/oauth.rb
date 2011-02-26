module Sorcery
  module Controller
    module Submodules
      # This submodule helps you login users from OAuth providers such as Twitter.
      # This is the controller part which handles the http requests and tokens passed between the app and the provider.
      # For more configuration options see Sorcery::Model::Oauth.
      module Oauth
        def self.included(base)
          base.send(:include, InstanceMethods)
          Config.module_eval do
            class << self
              attr_reader :oauth_providers                           # oauth providers like twitter.
              
              attr_accessor :user_providers_class
                            
              def merge_oauth_defaults!
                @defaults.merge!(:@oauth_providers => [],
                                 :@user_providers_class => nil)
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

        module InstanceMethods
          protected
          
          # requests a request_token
          # and then sends user to authorize with that token
          # after authorization the user is redirected to the callback defined in the provider config
          def login_with_provider(provider)
            provider_config = Config.send(provider)
            @callback_url = provider_config.callback_url
            @consumer = OAuth::Consumer.new(provider_config.key, provider_config.secret, :site => provider_config.site)
            @request_token = @consumer.get_request_token(:oauth_callback => @callback_url)
            session[:request_token] = @request_token
            redirect_to @request_token.authorize_url(:oauth_callback => @callback_url)
          end
          
          # tries to login the user from access token
          def login_from_access_token(access_token, access_token_secret)
            model_config = Config.user_class.sorcery_config
            user = Config.user_class.find_by_access_token(access_token, access_token_secret)
            if user
              reset_session # protect from session fixation attacks
              login_user(user)
              return user
            end
            false
          end
          
          def get_access_token(provider)
            provider_config = Config.send(provider)
            @request_token = session[:request_token]
            session[:request_token] = nil
            @access_token = @request_token.get_access_token
          end
          
          def get_user_hash(provider)
            provider_config = Config.send(provider)
            @user_hash = JSON.parse(@access_token.get(provider_config.user_info_path).body)
          end
        end
      end
    end
  end
end
