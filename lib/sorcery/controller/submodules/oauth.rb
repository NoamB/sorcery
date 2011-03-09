require 'oauth'
require 'oauth2'

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
              
              attr_accessor :authentications_class
                            
              def merge_oauth_defaults!
                @defaults.merge!(:@oauth_providers => [],
                                 :@authentications_class => nil)
              end
              
              def oauth_providers=(providers)
                providers.each do |provider|
                  include Providers.const_get(provider.to_s.split("_").map {|p| p.capitalize}.join(""))
                end
              end
            end
            merge_oauth_defaults!
          end
        end

        module InstanceMethods
          protected
          
          # requests a request_token
          # and then sends user to authenticate with that token
          # after authentication the user is redirected to the callback defined in the provider config
          def auth_at_provider(provider)
            @provider = Config.send(provider)
            if @provider.respond_to?(:get_request_token)
              args = {:request_token => @provider.get_request_token} 
              session[:request_token] = args[:request_token]
            end
            redirect_to @provider.authorize_url(args)
          end
          
          # tries to login the user from access token
          def login_from_access_token(provider)
            @provider = Config.send(provider)
            args = {}
            args.merge!({:oauth_verifier => params[:oauth_verifier], :request_token => session[:request_token]}) if @provider.respond_to?(:get_request_token)
            args.merge!({:code => params[:code]}) if params[:code]
            @access_token = @provider.get_access_token(args)
            if user = Config.user_class.load_from_access_token( @access_token )
              reset_session
              login_user(user)
              user
            end
          end
          
          def get_user_hash(provider)
            @provider = Config.send(provider)
            response = @access_token.get(@provider.user_info_path)
            @user_hash ||= JSON.parse(response.respond_to?(:body) ? response.body : response)
          end
        end
      end
    end
  end
end
