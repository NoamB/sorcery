module Sorcery
  module Controller
    module Submodules
      # This submodule helps you set a timeout to all user sessions.
      # The timeout can be configured and also you can choose to reset it on every user action.
      module SessionTimeout
        def self.included(base)
          base.send(:include, InstanceMethods)
          Config.module_eval do
            class << self
              attr_accessor :session_timeout,                     # how long in seconds to keep the session alive.

                            :session_timeout_from_last_action     # use the last action as the beginning of session
                                                                  # timeout.

              def merge_session_timeout_defaults!
                @defaults.merge!(:@session_timeout                      => 3600, # 1.hour
                                 :@session_timeout_from_last_action     => false)
              end
            end
            merge_session_timeout_defaults!
          end
          Config.after_login << :register_login_time
          base.prepend_before_filter :validate_session
        end

        module InstanceMethods
          protected

          # Registers last login to be used as the timeout starting point.
          # Runs as a hook after a successful login.
          def register_login_time(user, credentials)
            session[:login_time] = session[:last_action_time] = Time.now.in_time_zone
          end

          # Checks if session timeout was reached and expires the current session if so.
          # To be used as a before_filter, before require_login
          def validate_session
            session_to_use = Config.session_timeout_from_last_action ? session[:last_action_time] : session[:login_time]
            if session_to_use && sorcery_session_expired?(session_to_use.to_time)
              reset_sorcery_session
              @current_user = nil
            else
              session[:last_action_time] = Time.now.in_time_zone
            end
          end

          def sorcery_session_expired?(time)
            Time.now.in_time_zone - time > Config.session_timeout
          end

        end
      end
    end
  end
end
