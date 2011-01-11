module SimpleAuth
  module Model
    module Adapters
      # The ActiveRecord adapter adds all server-side validations, callbacks, and other goodies to the user class,
      # depending on included submodules.
      module ActiveRecord
        def self.included(base)
          base.class_eval do
            include InstanceMethods
            
            attr_accessor @simple_auth_config.password_attribute_name if @simple_auth_config.submodules.include?(:password_encryption)
            attr_accessor @simple_auth_config.password_confirmation_attribute_name if @simple_auth_config.submodules.include?(:password_confirmation)

            validate :password_confirmed if @simple_auth_config.submodules.include?(:password_confirmation)
            before_save :encrypt_password if @simple_auth_config.submodules.include?(:password_encryption)
          end
        end
        
        module InstanceMethods
          def encrypt_password
            config = simple_auth_config
            self.send(:"#{config.crypted_password_attribute_name}=", self.class.encrypt(self.send(config.password_attribute_name))) if self.new_record? || self.password
          end

          def password_confirmed
            config = simple_auth_config
            if self.send(config.password_attribute_name) && self.send(config.password_attribute_name) != self.send(config.password_confirmation_attribute_name)
              self.errors.add(:base,"password and password_confirmation do not match!")
            end
          end
        end
        
      end
    end
  end
end