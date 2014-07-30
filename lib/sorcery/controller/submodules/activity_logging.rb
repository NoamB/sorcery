module Sorcery
  module Controller
    module Submodules
      # This submodule keeps track of events such as login, logout,
      # and last activity time, per user.
      # It helps in estimating which users are active now in the site.
      # This cannot be determined absolutely because a user might be
      # reading a page without clicking anything for a while.
      # This is the controller part of the submodule, which adds hooks
      # to register user events,
      # and methods to collect active users data for use in the app.
      # see Socery::Model::Submodules::ActivityLogging for configuration
      # options.
      module ActivityLogging
        def self.included(base)
          base.send(:include, InstanceMethods)
          Config.module_eval do
            class << self
              attr_accessor :register_login_time
              attr_accessor :register_logout_time
              attr_accessor :register_last_activity_time
              attr_accessor :register_last_ip_address

              def merge_activity_logging_defaults!
                @defaults.merge!(:@register_login_time         => true,
                                 :@register_logout_time        => true,
                                 :@register_last_activity_time => true,
                                 :@register_last_ip_address    => true
                                 )
              end
            end
            merge_activity_logging_defaults!
          end
          Config.after_login    << :register_login_time_to_db
          Config.after_login    << :register_last_ip_address
          Config.before_logout  << :register_logout_time_to_db
          base.after_filter :register_last_activity_time_to_db
        end

        module InstanceMethods
          # Returns an array of the active users.
          def current_users
            ActiveSupport::Deprecation.warn("Sorcery: `current_users` method is deprecated. Read more on Github: https://github.com/NoamB/sorcery/issues/602")

            user_class.current_users
          end

          protected

          # registers last login time on every login.
          # This runs as a hook just after a successful login.
          def register_login_time_to_db(user, credentials)
            return unless Config.register_login_time
            user.set_last_login_at(Time.now.in_time_zone)
          end

          # registers last logout time on every logout.
          # This runs as a hook just before a logout.
          def register_logout_time_to_db(user)
            return unless Config.register_logout_time
            user.set_last_logout_at(Time.now.in_time_zone)
          end

          # Updates last activity time on every request.
          # The only exception is logout - we do not update activity on logout
          def register_last_activity_time_to_db
            return unless Config.register_last_activity_time
            return unless logged_in?
            current_user.set_last_activity_at(Time.now.in_time_zone)
          end

          # Updates IP address on every login.
          # This runs as a hook just after a successful login.
          def register_last_ip_address(user, credentials)
            return unless Config.register_last_ip_address
            current_user.set_last_ip_addess(request.remote_ip)
          end
        end
      end
    end
  end
end
