module Sorcery
  module Controller
    module Submodules
      # This submodule helps you login users from external auth providers such as Twitter.
      # This is the controller part which handles the http requests and tokens passed between the app and the provider.
      module External
        def self.included(base)
          base.send(:include, InstanceMethods)
          Config.module_eval do
            class << self
              attr_reader :external_providers                           # external providers like twitter.
              attr_accessor :ca_file                                    # path to ca_file. By default use a internal ca-bundle.crt.

              def merge_external_defaults!
                @defaults.merge!(:@external_providers => [],
                                 :@ca_file => File.join(File.expand_path(File.dirname(__FILE__)), 'external/protocols/certs/ca-bundle.crt'))
              end

              def external_providers=(providers)
                providers.each do |provider|
                  include Providers.const_get(provider.to_s.split("_").map {|p| p.capitalize}.join(""))
                end
              end
            end
            merge_external_defaults!
          end
        end

        module InstanceMethods
          protected

          # sends user to authenticate at the provider's website.
          # after authentication the user is redirected to the callback defined in the provider config
          def login_at(provider, args = {})
            @provider = Config.send(provider)
            if @provider.callback_url.present? && @provider.callback_url[0] == '/'
              uri = URI.parse(request.url.gsub(/\?.*$/,''))
              uri.path = ''
              uri.query = nil
              uri.scheme = 'https' if(request.env['HTTP_X_FORWARDED_PROTO'] == 'https')
              host = uri.to_s
              @provider.callback_url = "#{host}#{@provider.callback_url}"
            end
            if @provider.has_callback?
              redirect_to @provider.login_url(params,session)
            else
              #@provider.login(args)
            end
          end

          def get_id_from_provider(provider, uid)
            config = user_class.sorcery_config
            authentication = config.authentications_class.send("find_by_#{config.provider_attribute_name}_and_#{config.provider_uid_attribute_name}", provider, uid.to_s)
            return nil unless authentication
            authentication.send(config.authentications_user_id_attribute_name)
          end

          # tries to login the user from provider's callback
          def login_from(provider)
            @provider = Config.send(provider)
            @provider.process_callback(params,session)
            @user_hash = @provider.get_user_hash
            if user = user_class.load_from_provider(provider,@user_hash[:uid])
              return_to_url = session[:return_to_url]
              reset_session
              session[:return_to_url] = return_to_url
              auto_login(user)
              after_login!(user)
              user
            end
          end

          # get provider access account
          def access_token(provider)
            @provider = Config.send(provider)
            @provider.access_token
          end

          # If user is logged, he can add all available providers into his account
          def add_provider_to_user(provider)
            provider_name = provider.to_sym
            @provider = Config.send(provider_name)
            @provider.process_callback(params,session)
            @user_hash = @provider.get_user_hash
            config = user_class.sorcery_config

            # first check to see if user has a particular authentication already
            return false if get_id_from_provider(provider, @user_hash[:uid])

            user = current_user.add_provider(@user_hash[:uid], provider_name.to_s)
            user.save(:validate => false)
          end

          # Initialize new user from provider informations.
          # If a provider doesn't give required informations or username/email is already taken,
          # we store provider/user infos into a session and can be rendered into registration form
          def create_and_validate_from(provider)
            provider = provider.to_sym
            @provider = Config.send(provider)
            @user_hash = @provider.get_user_hash
            config = user_class.sorcery_config

            attrs = user_attrs(@provider.user_info_mapping, @user_hash)

            user = user_class.new(attrs)
            user.add_provider(@user_hash[:uid], provider)

            session[:incomplete_user] = {
              :provider => {config.provider_uid_attribute_name => @user_hash[:uid], config.provider_attribute_name => provider},
              :user_hash => attrs
            } unless user.save

            return user
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
          # Note: Be careful. This method skips validations model.
          # Instead you can pass a block, if the block returns false the user will not be created
          #
          #   create_from(provider) {|user| user.some_check }
          #
          def create_from(provider)
            provider = provider.to_sym
            @provider = Config.send(provider)
            @user_hash = @provider.get_user_hash
            config = user_class.sorcery_config

            attrs = user_attrs(@provider.user_info_mapping, @user_hash)

            user_class.transaction do
              @user = user_class.new()
              attrs.each do |k,v|
                @user.send(:"#{k}=", v)
              end

              if block_given?
                return false unless yield @user
              end

              @user.save(:validate => false)
              user_class.sorcery_config.authentications_class.create!({config.authentications_user_id_attribute_name => @user.id, config.provider_attribute_name => provider, config.provider_uid_attribute_name => @user_hash[:uid]})
            end
            @user
          end

          def user_attrs(user_info_mapping, user_hash)
            attrs = {}
            user_info_mapping.each do |k,v|
              if (varr = v.split("/")).size > 1
                attribute_value = varr.inject(user_hash[:user_info]) {|hash, value| hash[value]} rescue nil
                attribute_value.nil? ? attrs : attrs.merge!(k => attribute_value)
              else
                attrs.merge!(k => user_hash[:user_info][v])
              end
            end
            return attrs
          end
        end
      end
    end
  end
end
