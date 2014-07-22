module Sorcery
  module Model
    module Submodules
      # This submodule adds the ability to check/validate password for user (aka Devise's valid_password?).
      module PasswordValidation

        class ValidationError < StandardError; end

        def self.included(base)
          base.send(:include, InstanceMethods)
        end

        module InstanceMethods
          
          def valid_password?(pass)
            sorcery_config.encryption_provider.matches? self.send(:"#{sorcery_config.crypted_password_attribute_name}"), pass, self.send(:"#{sorcery_config.salt_attribute_name}")
          end

          def validate_password!(pass)
            unless self.valid_password?(pass)
              raise ValidationError    
            end
          end
        end
      end
    end
  end
end
