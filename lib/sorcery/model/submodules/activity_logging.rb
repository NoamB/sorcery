module Sorcery
  module Model
    module Submodules
      module ActivityLogging
        def self.included(base)
          base.extend(ClassMethods)
          base.sorcery_config.class_eval do
            attr_accessor :last_login_attribute_name,                     # last login attribute name.
                          :last_logout_attribute_name                    # last logout attribute name.
          end
          
          base.sorcery_config.instance_eval do
            @defaults.merge!(:@last_login_attribute_name                   => :last_login,
                             :@last_logout_attribute_name                  => :last_logout)
            reset!
          end
        end
        
        module ClassMethods
          # get all users with last login > last logout, 
          # which are within session_timeout (if submodule included) or within defined time
          def logged_in_users
            config = sorcery_config
            where("#{config.last_login_attribute_name} IS NOT NULL AND (#{config.last_logout_attribute_name} IS NULL OR #{config.last_login_attribute_name}>#{config.last_logout_attribute_name})")
          end
        end
      end
    end
  end
end