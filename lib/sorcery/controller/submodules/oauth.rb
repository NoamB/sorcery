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
                                          
              def merge_oauth_defaults!
                @defaults.merge!(:@oauth_providers => [])
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
          
          # sends user to authenticate at the provider's website.
          # after authentication the user is redirected to the callback defined in the provider config
          def auth_at_provider(provider)
            @provider = Config.send(provider)
            args = {}
            if @provider.respond_to?(:get_request_token)
              req_token = @provider.get_request_token
              session[:request_token]         = req_token.token
              session[:request_token_secret]  = req_token.secret
              args.merge!({:request_token => req_token.token, :request_token_secret => req_token.secret})
            end
            redirect_to @provider.authorize_url(args)
          end
          
          # tries to login the user from access token
          def login_from_access_token(provider)
            @provider = Config.send(provider)
            args = {}
            args.merge!({:oauth_verifier => params[:oauth_verifier], :request_token => session[:request_token], :request_token_secret => session[:request_token_secret]}) if @provider.respond_to?(:get_request_token)
            args.merge!({:code => params[:code]}) if params[:code]
            @access_token = @provider.get_access_token(args)
            @user_hash = @provider.get_user_hash(@access_token)
            if user = Config.user_class.load_from_provider(provider,@user_hash[:uid])
              reset_session
              login_user(user)
              user
            end
          end
          
          def get_user_hash(provider)
            @provider = Config.send(provider)
            @provider.get_user_hash(@access_token)
          end
          
          # this method automatically creates a new user from the data in the external user hash.
          # The mappings from user hash fields to user db fields are set at controller config.
          # If the hash field you would like to map is nested, use slashes. For example, Given a hash like:
          #
          #   "user" => {"name"=>"moishe"}
          #
          # You will set the mapping:
          #
          #   {:username => "user/name"}
          #
          # And this will cause 'moishe' to be set as the value of :username field.
          def create_from_provider!(provider)
            provider = provider.to_sym
            @provider = Config.send(provider)
            @user_hash = get_user_hash(provider)
            config = Config.user_class.sorcery_config
            attrs = {}
            @provider.user_info_mapping.each do |k,v|
              (varr = v.split("/")).size > 1 ? attrs.merge!(k => varr.inject(@user_hash[:user_info]) {|hsh,v| hsh[v] }) : attrs.merge!(k => @user_hash[:user_info][v])
            end
            Config.user_class.transaction do
              @user = Config.user_class.create!(attrs)
              Config.user_class.sorcery_config.authentications_class.create!({config.authentications_user_id_attribute_name => @user.id, config.provider_attribute_name => provider, config.provider_uid_attribute_name => @user_hash[:uid]})
            end
            @user
          end
        end
      end
    end
  end
end
