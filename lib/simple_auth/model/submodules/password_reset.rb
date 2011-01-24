module SimpleAuth
  module Model
    module Submodules
      # This submodule adds the ability to reset his password.
      module PasswordReset        
        def self.included(base)
          base.simple_auth_config.class_eval do
            attr_accessor :reset_password_code_attribute_name,
                          :simple_auth_mailer,
                          :reset_password_email_method_name

          end
          
          base.simple_auth_config.instance_eval do
            @defaults.merge!(:@reset_password_code_attribute_name => :reset_password_code,
                             :@simple_auth_mailer                 => nil,
                             :@reset_password_email_method_name   => :reset_password_email)

            reset!
          end
          
          base.class_eval do
            clear_reset_password_code_proc = Proc.new do |record|
              begin 
                record.valid? && record.send(:"#{simple_auth_config.password_attribute_name}_changed?")
              rescue
                record.valid? && record.send(simple_auth_config.password_attribute_name)
              end
            end
            
            before_save :clear_reset_password_code, :if =>clear_reset_password_code_proc
          end
          
          base.send(:include, InstanceMethods)
        end
        
        module InstanceMethods
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
        
      end
    end
  end
end