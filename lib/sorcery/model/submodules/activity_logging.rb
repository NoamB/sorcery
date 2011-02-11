module Sorcery
  module Model
    module Submodules
      module ActivityLogging
        def self.included(base)
          base.extend(ClassMethods)
          base.sorcery_config.class_eval do
            attr_accessor :last_login_at_attribute_name,                     # last login attribute name.
                          :last_logout_at_attribute_name,                    # last logout attribute name.
                          :last_activity_at_attribute_name,                  # last activity attribute name.
                          :activity_timeout                               # how long since last activity is the user defined logged out?
          end
          
          base.sorcery_config.instance_eval do
            @defaults.merge!(:@last_login_at_attribute_name                   => :last_login_at,
                             :@last_logout_at_attribute_name                  => :last_logout_at,
                             :@last_activity_at_attribute_name                => :last_activity_at,
                             :@activity_timeout                            => 10.minutes)
            reset!
          end
        end
        
        module ClassMethods
          # get all users with last_activity within timeout
          def logged_in_users
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