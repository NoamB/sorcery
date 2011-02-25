module Sorcery
  module Model
    module Submodules

      module Oauth
        def self.included(base)
          base.sorcery_config.class_eval do
            attr_accessor :user_providers_class,
                          :user_providers_user_id_attribute_name,
                          :access_token_attribute_name,
                          :access_token_secret_attribute_name

          end
          
          base.sorcery_config.instance_eval do
            @defaults.merge!(:@user_providers_class                  => Sorcery::Controller::Config.user_class,
                             :@user_providers_user_id_attribute_name => :user_id,
                             :@access_token_attribute_name           => :access_token,
                             :@access_token_secret_attribute_name    => :access_token_secret)

            reset!
          end
          
          base.send(:include, InstanceMethods)
          base.extend(ClassMethods)
        end
        
        module ClassMethods
          def find_by_access_token(access_token, access_token_secret)
            config = sorcery_config
            user_provider = config.user_providers_class.where("#{config.access_token_attribute_name} = ? AND #{config.access_token_secret_attribute_name} = ?", access_token, access_token_secret).first
            user = find(user_provider.send(config.user_providers_user_id_attribute_name)) if user_provider
          end
        end
        
        module InstanceMethods

        end
      
      end
    end
  end
end