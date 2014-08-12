module Sorcery
  module Model
    module Submodules
      # This submodule keeps track of events such as login, logout, and last activity time, per user.
      # It helps in estimating which users are active now in the site.
      # This cannot be determined absolutely because a user might be reading a page without clicking anything
      # for a while.
      # This is the model part of the submodule, which provides configuration options.
      module ActivityLogging
        def self.included(base)
          base.extend(ClassMethods)
          base.send(:include, InstanceMethods)

          base.sorcery_config.class_eval do
            attr_accessor :last_login_at_attribute_name,                  # last login attribute name.
                          :last_logout_at_attribute_name,                 # last logout attribute name.
                          :last_activity_at_attribute_name,               # last activity attribute name.
                          :last_login_from_ip_address_name,               # last activity login source
                          :activity_timeout                               # how long since last activity is
                                                                          #the user defined logged out?
          end

          base.sorcery_config.instance_eval do
            @defaults.merge!(:@last_login_at_attribute_name                => :last_login_at,
                             :@last_logout_at_attribute_name               => :last_logout_at,
                             :@last_activity_at_attribute_name             => :last_activity_at,
                             :@last_login_from_ip_address_name             => :last_login_from_ip_address,
                             :@activity_timeout                            => 10 * 60)
            reset!
          end

          base.sorcery_config.after_config << :define_activity_logging_fields
        end

        module InstanceMethods
          def set_last_login_at(time)
            sorcery_adapter.update_attribute(sorcery_config.last_login_at_attribute_name, time)
          end

          def set_last_logout_at(time)
            sorcery_adapter.update_attribute(sorcery_config.last_logout_at_attribute_name, time)
          end

          def set_last_activity_at(time)
            sorcery_adapter.update_attribute(sorcery_config.last_activity_at_attribute_name, time)
          end

          def set_last_ip_addess(ip_address)
            sorcery_adapter.update_attribute(sorcery_config.last_login_from_ip_address_name, ip_address)
          end
        end

        module ClassMethods
          # get all users with last_activity within timeout
          def current_users
            sorcery_adapter.get_current_users
          end

          protected
          def define_activity_logging_fields
            sorcery_adapter.define_field sorcery_config.last_login_at_attribute_name,    Time
            sorcery_adapter.define_field sorcery_config.last_logout_at_attribute_name,   Time
            sorcery_adapter.define_field sorcery_config.last_activity_at_attribute_name, Time
            sorcery_adapter.define_field sorcery_config.last_login_from_ip_address_name, String
          end
        end
      end
    end
  end
end
