module Sorcery
  module Model
    module Submodules
      # This submodule adds the ability to reset password via email confirmation.
      module PasswordReset        
        def self.included(base)
          base.sorcery_config.class_eval do
            attr_accessor :reset_password_code_attribute_name,
                          :sorcery_mailer,
                          :reset_password_email_method_name

          end
          
          base.sorcery_config.instance_eval do
            @defaults.merge!(:@reset_password_code_attribute_name => :reset_password_code,
                             :@sorcery_mailer                     => nil,
                             :@reset_password_email_method_name   => :reset_password_email)

            reset!
          end
          
          base.class_eval do
            clear_reset_password_code_proc = Proc.new do |record|
              record.valid? && record.send(sorcery_config.password_attribute_name)
            end
            
            before_save :clear_reset_password_code, :if =>clear_reset_password_code_proc
          end
          
          base.send(:include, InstanceMethods)
        end
        
        module InstanceMethods
          def reset_password!
            config = sorcery_config
            self.send(:"#{config.reset_password_code_attribute_name}=", generate_random_code)
            self.class.transaction do
              self.save!
              generic_send_email(:reset_password_email_method_name)
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