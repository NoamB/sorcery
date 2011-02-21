module Sorcery
  module Model
    module Submodules
      # This submodule keeps track of events such as login, logout, and last activity time, per user.
      # It helps in estimating which users are active now in the site.
      # This cannot be determined absolutely because a user might be reading a page without clicking anything for a while.
      
      # This is the model part of the submodule, which provides configuration options.
      module ActivityLogging
        def self.included(base)
          base.extend(ClassMethods)
          base.sorcery_config.class_eval do
            attr_accessor :last_login_at_attribute_name,                  # last login attribute name.
                          :last_logout_at_attribute_name,                 # last logout attribute name.
                          :last_activity_at_attribute_name,               # last activity attribute name.
                          :activity_timeout                               # how long since last activity is the user defined logged out?
          end
          
          base.sorcery_config.instance_eval do
            @defaults.merge!(:@last_login_at_attribute_name                => :last_login_at,
                             :@last_logout_at_attribute_name               => :last_logout_at,
                             :@last_activity_at_attribute_name             => :last_activity_at,
                             :@activity_timeout                            => 10.minutes)
            reset!
          end
        end
        
        module ClassMethods
          # get all users with last_activity within timeout
          def current_users
            config = sorcery_config
            where("#{config.last_activity_at_attribute_name} IS NOT NULL") \
            .where("#{config.last_logout_at_attribute_name} IS NULL OR #{config.last_activity_at_attribute_name} > #{config.last_logout_at_attribute_name}") \
            .where("#{config.last_activity_at_attribute_name} > ? ", config.activity_timeout.seconds.ago)
          end
        end
      end
    end
  end
end