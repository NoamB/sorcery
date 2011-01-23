module SimpleAuth
  module Model
    module Submodules
      module RememberMe
        def self.included(base)
          base.simple_auth_config.class_eval do
            attr_accessor :remember_me_token_attribute_name,
                          :remember_me_token_expires_at_attribute_name,
                          :remember_me_for

          end
          
          base.simple_auth_config.instance_eval do
            @defaults.merge!(:@remember_me_token_attribute_name => :remember_me_token,
                             :@remember_me_token_expires_at_attribute_name => :remember_me_token_expires_at,
                             :@remember_me_for => 7 * 60 * 60 * 24)

            reset!
          end
          
        end
        
      end
    end
  end
end