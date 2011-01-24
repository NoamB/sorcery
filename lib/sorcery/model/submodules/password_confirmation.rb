module Sorcery
  module Model
    module Submodules
      # This submodule adds the ability to verify that the user filled the password twice,
      # and that both times were the same string.
      module PasswordConfirmation
        def self.included(base)
          # changes to the Sorcery::Model::Config class
          base.sorcery_config.class_eval do
            attr_accessor :password_confirmation_attribute_name
          end
          
          # changes to sorcery_config class instance variable
          base.sorcery_config.instance_eval do
            @defaults.merge!(:@password_confirmation_attribute_name => :password_confirmation)
            reset!
          end
          
          # changes to the actual model
          base.class_eval do
            attr_accessor @sorcery_config.password_confirmation_attribute_name
            validate :password_confirmed
          end
          
          base.send(:include, InstanceMethods)
        end
        
        module InstanceMethods
          protected

          def password_confirmed
            config = sorcery_config
            if self.send(config.password_attribute_name) && self.send(config.password_attribute_name) != self.send(config.password_confirmation_attribute_name)
              self.errors.add(:base,"password and password_confirmation do not match!")
            end
          end
        end
      end
    end
  end
end