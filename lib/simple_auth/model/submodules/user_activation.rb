module SimpleAuth
  module Model
    module Submodules
      # This submodule adds the ability to make the user activate his account via email
      # or any other way in which he can recieve an activation code.
      # with the activation code the use may activate his account.
      module UserActivation
        def self.included(base)
          base.simple_auth_config.class_eval do
            attr_accessor :activation_state_attribute_name,
                          :activation_code_attribute_name,
                          :simple_auth_mailer,
                          :activation_email_method_name
          end
          
          base.simple_auth_config.instance_eval do
            @defaults.merge!(:@activation_state_attribute_name => :activation_state,
                             :@activation_code_attribute_name  => :activation_code,
                             :@simple_auth_mailer              => SimpleAuthMailer,
                             :@activation_email_method_name    => :activation_email)
            reset!
          end
        end
        
        class SimpleAuthMailer < ActionMailer::Base
          template_root = File.dirname(__FILE__)
          
          default :from => "notifications@example.com"
          
          def activation_email(user, simple_auth_config)
            @user = user
            @url  = "http://example.com/login"
            mail(:to => user.send(simple_auth_config.email_attribute_name),
                 :subject => "Welcome to My Awesome Site")
          end
        end
        
      end
    end
  end
end