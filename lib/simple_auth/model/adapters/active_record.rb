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
            before_save :setup_activation if @simple_auth_config.submodules.include?(:user_activation)
            before_save :encrypt_password if @simple_auth_config.submodules.include?(:password_encryption)
            after_save :send_activation_email if @simple_auth_config.submodules.include?(:user_activation)
          end
        end
        
        module InstanceMethods
          def activate!
            config = simple_auth_config
            self.send(:"#{config.activation_code_attribute_name}=", nil)
            self.send(:"#{config.activation_state_attribute_name}=", "active")
          end
          
          protected
          
          def encrypt_password
            config = simple_auth_config
            salt = ""
            if !config.salt_attribute_name.nil?
              salt = Time.now.to_s
              self.send(:"#{config.salt_attribute_name}=", salt)
            end
            self.send(:"#{config.crypted_password_attribute_name}=", self.class.encrypt(self.send(config.password_attribute_name),salt)) if self.new_record? || self.password
          end

          def password_confirmed
            config = simple_auth_config
            if self.send(config.password_attribute_name) && self.send(config.password_attribute_name) != self.send(config.password_confirmation_attribute_name)
              self.errors.add(:base,"password and password_confirmation do not match!")
            end
          end
          
          def setup_activation
            config = simple_auth_config
            generated_activation_code = CryptoProviders::SHA1.encrypt( Time.now.to_s.split(//).sort_by {rand}.join )
            self.send(:"#{config.activation_code_attribute_name}=", generated_activation_code)
            self.send(:"#{config.activation_state_attribute_name}=", "pending")
          end
          
          def send_activation_email
            config = simple_auth_config
            mail = config.simple_auth_mailer.send(config.activation_needed_email_method_name,self)
            if defined?(ActionMailer) and config.simple_auth_mailer.superclass == ActionMailer::Base
              mail.deliver
            end
          end
        end
        
      end
    end
  end
end