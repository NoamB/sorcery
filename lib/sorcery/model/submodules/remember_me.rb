module Sorcery
  module Model
    module Submodules
      # The Remember Me submodule takes care of setting the user's cookie so that he will
      # be automatically logged in to the site on every visit,
      # until the cookie expires.
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
          base.sorcery_config.after_config << :define_remember_me_fields

          base.extend(ClassMethods)
        end

        module ClassMethods
          protected

          def define_remember_me_fields
            sorcery_adapter.define_field sorcery_config.remember_me_token_attribute_name, String
            sorcery_adapter.define_field sorcery_config.remember_me_token_expires_at_attribute_name, Time
          end

        end

        module InstanceMethods
          # You shouldn't really use this one yourself - it's called by the controller's 'remember_me!' method.
          def remember_me!
            config = sorcery_config
            self.sorcery_adapter.update_attributes(config.remember_me_token_attribute_name => TemporaryToken.generate_random_token,
                                        config.remember_me_token_expires_at_attribute_name => Time.now.in_time_zone + config.remember_me_for)
          end

          def has_remember_me_token?
            self.send(sorcery_config.remember_me_token_attribute_name).present?
          end

          # You shouldn't really use this one yourself - it's called by the controller's 'forget_me!' method.
          def forget_me!
            config = sorcery_config
            self.sorcery_adapter.update_attributes(config.remember_me_token_attribute_name => nil,
                                        config.remember_me_token_expires_at_attribute_name => nil)
          end
        end
      end
    end
  end
end
