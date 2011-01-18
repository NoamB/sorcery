module SimpleAuth
  module Model
    module Adapters
      # The ActiveRecord adapter adds all server-side validations, callbacks, and other goodies to the user class,
      # depending on included submodules.
      module ActiveRecord
        def self.included(base)
          base.class_eval do
              
            if @simple_auth_config.submodules.include?(:password_encryption)
              attr_accessor @simple_auth_config.password_attribute_name
              include PasswordEncryptionMethods
              before_save :encrypt_password
            end
            
            if @simple_auth_config.submodules.include?(:password_confirmation)
              attr_accessor @simple_auth_config.password_confirmation_attribute_name
              include PasswordConfirmationMethods 
              validate :password_confirmed
            end
            
            if @simple_auth_config.submodules.include?(:user_activation)
              include UserActivationMethods
              before_create :setup_activation
              after_create :send_activation_needed_email!
            end

          end
        end
        
        # Adds password confirmation validation
        module PasswordConfirmationMethods
          
          protected
          
          def password_confirmed
            config = simple_auth_config
            if self.send(config.password_attribute_name) && self.send(config.password_attribute_name) != self.send(config.password_confirmation_attribute_name)
              self.errors.add(:base,"password and password_confirmation do not match!")
            end
          end
        end
        
        # Adds methods to activate users, and send activation emails
        module UserActivationMethods
          def activate!
            config = simple_auth_config
            self.send(:"#{config.activation_code_attribute_name}=", nil)
            self.send(:"#{config.activation_state_attribute_name}=", "active")
            send_activation_success_email!
          end
          
          protected
          
          def setup_activation
            config = simple_auth_config
            generated_activation_code = CryptoProviders::SHA1.encrypt( Time.now.to_s.split(//).sort_by {rand}.join )
            self.send(:"#{config.activation_code_attribute_name}=", generated_activation_code)
            self.send(:"#{config.activation_state_attribute_name}=", "pending")
          end
        
          def send_activation_needed_email!
            config = simple_auth_config
            mail = config.simple_auth_mailer.send(config.activation_needed_email_method_name,self)
            if defined?(ActionMailer) and config.simple_auth_mailer.superclass == ActionMailer::Base
              mail.deliver
            end
          end
        
          def send_activation_success_email!
            config = simple_auth_config
            mail = config.simple_auth_mailer.send(config.activation_success_email_method_name,self)
            if defined?(ActionMailer) and config.simple_auth_mailer.superclass == ActionMailer::Base
              mail.deliver
            end
          end
        end
        
        # Adds a method to encrypt password on save
        module PasswordEncryptionMethods
          
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

        end
          
      end
    end
  end
end