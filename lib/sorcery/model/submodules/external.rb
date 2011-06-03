module Sorcery
  module Model
    module Submodules
      # This submodule helps you login users from external providers such as Twitter.
      # This is the model part which handles finding the user using access tokens.
      # For the controller options see Sorcery::Controller::External.
      #
      # Socery assumes (read: requires) you will create external users in the same table where
      # you keep your regular users,
      # but that you will have a separate table for keeping their external authentication data,
      # and that that separate table has a few rows for each user, facebook and twitter 
      # for example (a one-to-many relationship).
      #
      # External users will have a null crypted_password field, since we do not hold their password.
      # They will not be sent activation emails on creation.
      module External
        def self.included(base)
          base.sorcery_config.class_eval do
            attr_accessor :authentications_class,
                          :authentications_user_id_attribute_name,
                          :provider_attribute_name,
                          :provider_uid_attribute_name

          end
          
          base.sorcery_config.instance_eval do
            @defaults.merge!(:@authentications_class                  => nil,
                             :@authentications_user_id_attribute_name => :user_id,
                             :@provider_attribute_name                => :provider,
                             :@provider_uid_attribute_name            => :uid)

            reset!
          end
          
          base.send(:include, InstanceMethods)
          base.extend(ClassMethods)

        end
        
        module ClassMethods
          # takes a provider and uid and finds a user by them.
          def load_from_provider(provider,uid)
            config = sorcery_config
            authentication = config.authentications_class.find_by_provider_and_uid(provider, uid)
            user = find(authentication.send(config.authentications_user_id_attribute_name)) if authentication
          end
        end
        
        module InstanceMethods

        end
      
      end
    end
  end
end