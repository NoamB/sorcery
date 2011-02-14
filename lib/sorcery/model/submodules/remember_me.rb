module Sorcery
  module Model
    module Submodules
      module RememberMe
        def self.included(base)
          base.sorcery_config.class_eval do
            attr_accessor :remember_me_token_attribute_name,              # the attribute in the model class.
                          :remember_me_token_expires_at_attribute_name,   # the expires attribute in the model class.
                          :remember_me_for                                # how long in seconds to remember.

          end
          
          base.sorcery_config.instance_eval do
            @defaults.merge!(:@remember_me_token_attribute_name            => :remember_me_token,
                             :@remember_me_token_expires_at_attribute_name => :remember_me_token_expires_at,
                             :@remember_me_for                             => 7 * 60 * 60 * 24)

            reset!
          end
          
          base.send(:include, InstanceMethods)
        end
        
        module InstanceMethods
          # You shouldn't really use this one - it's called by the controller's 'remember_me!' method.
          def remember_me!
            config = sorcery_config
            self.send(:"#{config.remember_me_token_attribute_name}=", generate_random_code)
            self.send(:"#{config.remember_me_token_expires_at_attribute_name}=", Time.now + config.remember_me_for)
            self.save!(:validate => false)
          end
          
          # You shouldn't really use this one - it's called by the controller's 'forget_me!' method.
          def forget_me!
            config = sorcery_config
            self.send(:"#{config.remember_me_token_attribute_name}=", nil)
            self.send(:"#{config.remember_me_token_expires_at_attribute_name}=", nil)
            self.save!(:validate => false)
          end
        end
      end
    end
  end
end