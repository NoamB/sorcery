module Sorcery
  module Model
    module Submodules
      # This submodule adds the ability to reset password via email confirmation.
      module PasswordReset        
        def self.included(base)
          base.sorcery_config.class_eval do
            attr_accessor :reset_password_code_attribute_name,        # reset password code attribute name.
                          :reset_password_mailer,                     # mailer class. Needed.
                          :reset_password_email_method_name           # reset password email method on your mailer class.

          end
          
          base.sorcery_config.instance_eval do
            @defaults.merge!(:@reset_password_code_attribute_name => :reset_password_code,
                             :@reset_password_mailer              => nil,
                             :@reset_password_email_method_name   => :reset_password_email)

            reset!
          end
          
          base.class_eval do
            clear_reset_password_code_proc = Proc.new do |record|
              record.valid? && record.send(sorcery_config.password_attribute_name)
            end
            
            before_save :clear_reset_password_code, :if =>clear_reset_password_code_proc
          end
          
          base.sorcery_config.after_config << :validate_mailer_defined
          
          base.extend(ClassMethods)
          base.send(:include, InstanceMethods)
        end
        
        module ClassMethods
          def validate_mailer_defined
            msg = "To use password_reset submodule, you must define a mailer (config.reset_password_mailer = YourMailerClass)."
            raise ArgumentError, msg if @sorcery_config.reset_password_mailer == nil
          end
        end
        
        module InstanceMethods
          def reset_password!
            config = sorcery_config
            self.send(:"#{config.reset_password_code_attribute_name}=", generate_random_code)
            self.class.transaction do
              self.save!(:validate => false)
              generic_send_email(:reset_password_email_method_name, :reset_password_mailer)
            end
          end

          protected

          def clear_reset_password_code
            config = sorcery_config
            self.send(:"#{config.reset_password_code_attribute_name}=", nil)
          end
        end
        
      end
    end
  end
end