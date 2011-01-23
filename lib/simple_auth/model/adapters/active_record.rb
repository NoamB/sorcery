module SimpleAuth
  module Model
    module Adapters
      # The ActiveRecord adapter adds all server-side validations, callbacks, and other goodies to the user class,
      # depending on included submodules.
      module ActiveRecord
        def self.included(base)
          base.class_eval do
            # This proc
            clear_reset_password_code_proc = Proc.new {|record| record.valid? && record.send(:"#{simple_auth_config.password_attribute_name}_changed?")}
            
            if @simple_auth_config.submodules.include?(:password_encryption)
              attr_accessor @simple_auth_config.password_attribute_name
              include PasswordEncryptionMethods
              clear_reset_password_code_proc = Proc.new {|record| record.valid? && record.send(simple_auth_config.password_attribute_name)} if @simple_auth_config.submodules.include?(:password_reset)
              before_save :encrypt_password, :if => Proc.new {|record| record.new_record? || record.send(simple_auth_config.password_attribute_name)}
              after_save :clear_virtual_password, :if => Proc.new {|record| record.valid? && record.send(simple_auth_config.password_attribute_name)}
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
            
            if @simple_auth_config.submodules.include?(:password_reset)
              include PasswordResetMethods
              before_save :clear_reset_password_code, :if =>clear_reset_password_code_proc
            end
            
            if @simple_auth_config.submodules.include?(:remember_me)
              include RememberMeMethods
            end
            
            protected
            
            def generic_send_email(method)
              config = simple_auth_config
              mail = config.simple_auth_mailer.send(config.send(method),self)
              if defined?(ActionMailer) and config.simple_auth_mailer.superclass == ActionMailer::Base
                mail.deliver
              end
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
            generic_send_email(:activation_needed_email_method_name)
          end
        
          def send_activation_success_email!
            generic_send_email(:activation_success_email_method_name)
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
            self.send(:"#{config.crypted_password_attribute_name}=", self.class.encrypt(self.send(config.password_attribute_name),salt))
          end

          def clear_virtual_password
            config = simple_auth_config
            self.send(:"#{config.password_attribute_name}=", nil)
          end
        end
        
        module PasswordResetMethods
          def reset_password!
            config = simple_auth_config
            self.send(:"#{config.reset_password_code_attribute_name}=", generate_random_code)
            self.class.transaction do
              self.save!
              generic_send_email(:reset_password_email_method_name)
            end
          end
          
          protected
          
          def clear_reset_password_code
            config = simple_auth_config
            self.send(:"#{config.reset_password_code_attribute_name}=", nil)
          end
          
          # TODO: duplicate
          def generate_random_code
            return Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
          end
        end
        
        module RememberMeMethods
          def remember_me!
            config = simple_auth_config
            self.send(:"#{config.remember_me_token_attribute_name}=", generate_random_code)
            self.send(:"#{config.remember_me_token_expires_at_attribute_name}=", Time.now + config.remember_me_for)
            self.save!
          end
          
          def forget_me!
            config = simple_auth_config
            self.send(:"#{config.remember_me_token_attribute_name}=", nil)
            self.send(:"#{config.remember_me_token_expires_at_attribute_name}=", nil)
            self.save!
          end
          
          # TODO: duplicate
          def generate_random_code
            return Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
          end
        end
      end
    end
  end
end