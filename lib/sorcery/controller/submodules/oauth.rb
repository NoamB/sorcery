require 'rubygems'
require 'bundler/setup'
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
          # and then sends user to authenticate with that token
          # after authentication the user is redirected to the callback defined in the provider config
          def auth_at_provider(provider)
            @provider_config = Config.send(provider)
            @callback_url = @provider_config.callback_url
            
            # TODO: the flows for oauth1 and oauth2 will be extracted to respective modules and mixed into the relevant providers.
            # The creation of version specific objects will be done via 1 call to the provider, and not via an "if" statement.
            @provider_config.oauth_version =~ /^1.0/ ? oauth1_flow : oauth2_flow
          end
          
          def oauth1_flow
            @consumer = ::OAuth::Consumer.new(@provider_config.key, @provider_config.secret, :site => @provider_config.site)
            @request_token = @consumer.get_request_token(:oauth_callback => @callback_url)
            session[:request_token] = @request_token
            redirect_to @request_token.authorize_url(:oauth_callback => @callback_url)
          end
          
          def oauth2_flow
            @client = ::OAuth2::Client.new(@provider_config.key, @provider_config.secret, :site => @provider_config.site)
            session[:client] = @client
            session[:callback_url] = @callback_url
            redirect_to @client.web_server.authorize_url(:redirect_uri => @callback_url, :scope => 'email,offline_access')
          end
          
          # tries to login the user from access token
          def login_from_access_token
            if user = Config.user_class.load_from_access_token( params[:oauth_verifier] ? get_access_token( params[:oauth_verifier] ) : get_access_token2 )
              reset_session
              login_user(user)
              user
            end
          end
          
          def get_access_token(oauth_verifier = nil)
            @access_token ||= lambda do 
              @request_token = session[:request_token]
              session[:request_token] = nil
              @request_token.get_access_token(:oauth_verifier => oauth_verifier)
            end.call
          end
          
          def get_access_token2
            @access_token ||= lambda do
              @client = session[:client]
              @callback_url = session[:callback_url]
              session[:client] = nil
              @client.web_server.get_access_token(params[:code], :redirect_uri => @callback_url)
            end.call
          end
          
          def get_user_hash(provider)
            response = @access_token.get(Config.send(provider).user_info_path)
            @user_hash ||= JSON.parse(response.respond_to?(:body) ? response.body : response)
          end
        end
      end
    end
  end
end
