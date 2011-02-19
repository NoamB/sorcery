module Sorcery
  module Controller
    module Submodules
      module BruteForceProtection
        def self.included(base)
          base.send(:include, InstanceMethods)

          Config.after_login << :reset_failed_logins_count!
          Config.after_failed_login << :update_failed_logins_count!
        end
        
        module InstanceMethods
          
          protected
          
          def update_failed_logins_count!(credentials)
            user = User.where("#{User.sorcery_config.username_attribute_name} = ?", credentials[0]).first
            user.register_failed_login! if user
          end
          
          def reset_failed_logins_count!(user, credentials)
            user.update_attributes!(User.sorcery_config.failed_logins_count_attribute_name => 0)
          end
        end
      end
    end
  end
end