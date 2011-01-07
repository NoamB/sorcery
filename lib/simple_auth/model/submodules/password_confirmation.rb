module SimpleAuth
  module Model
    module Submodules
      module PasswordConfirmation
        def self.included(base)
          base.simple_auth_config.class_eval do
            attr_accessor :password_confirmation_attribute_name
          end
          
          base.simple_auth_config.instance_eval do
            @defaults.merge!(:@password_confirmation_attribute_name => :password_confirmation)
            reset!
          end
        end
      end
    end
  end
end