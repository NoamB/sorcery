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
          
          base.class_eval do
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
end