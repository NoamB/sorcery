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
          
        end
        
      end
    end
  end
end