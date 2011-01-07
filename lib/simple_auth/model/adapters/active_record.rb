module SimpleAuth
  module Model
    module Adapters
      module ActiveRecord
        def self.included(base)
          base.class_eval do
            include InstanceMethods
            
            attr_accessor @config.password_attribute_name
            attr_accessor @config.password_confirmation_attribute_name if @config.submodules.include?(:password_confirmation)

            validate :password_confirmed if @config.submodules.include?(:password_confirmation)
            before_save :encrypt_password
          end
        end
        
        module InstanceMethods
          def encrypt_password
            config = self.class.simple_auth_config
            self.send(:"#{config.crypted_password_attribute_name}=", self.class.encrypt(self.send(config.password_attribute_name))) if self.new_record? || self.password
          end

          def password_confirmed
            config = self.class.simple_auth_config
            if self.send(config.password_attribute_name) && self.send(config.password_attribute_name) != self.send(config.password_confirmation_attribute_name)
              self.errors.add(:base,"password and password_confirmation do not match!")
            end
          end
        end
        
      end
    end
  end
end