module Sorcery
  module Model
    module Submodules
      module RememberMe
        def self.included(base)
          base.sorcery_config.class_eval do
            attr_accessor :remember_me_token_attribute_name,
                          :remember_me_token_expires_at_attribute_name,
                          :remember_me_for

          end
          
          base.sorcery_config.instance_eval do
            @defaults.merge!(:@remember_me_token_attribute_name => :remember_me_token,
                             :@remember_me_token_expires_at_attribute_name => :remember_me_token_expires_at,
                             :@remember_me_for => 7 * 60 * 60 * 24)

            reset!
          end
          
          base.send(:include, InstanceMethods)
        end
        
        module InstanceMethods
          def remember_me!
            config = sorcery_config
            self.send(:"#{config.remember_me_token_attribute_name}=", generate_random_code)
            self.send(:"#{config.remember_me_token_expires_at_attribute_name}=", Time.now + config.remember_me_for)
            self.save!
          end

          def forget_me!
            config = sorcery_config
            self.send(:"#{config.remember_me_token_attribute_name}=", nil)
            self.send(:"#{config.remember_me_token_expires_at_attribute_name}=", nil)
            self.save!
          end
        end
      end
    end
  end
end