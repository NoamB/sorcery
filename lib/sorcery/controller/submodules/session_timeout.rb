module Sorcery
  module Controller
    module Submodules
      module SessionTimeout
        def self.included(base)
          base.send(:include, InstanceMethods)
          Config.module_eval do
            class << self
              attr_accessor :session_timeout,
                            :session_timeout_from_last_action
                            
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
          def register_login_time(user, credentials)
            session[:login_time] = session[:last_action_time] = Time.now.utc
          end
          
          # To be used as a before_filter, before authenticate
          def validate_session
            session_to_use = Config.session_timeout_from_last_action ? session[:last_action_time] : session[:login_time]
            if session_to_use && (Time.now.utc - session_to_use > Config.session_timeout)
              reset_session
              @logged_in_user = false
            else
              session[:last_action_time] = Time.now.utc
            end
          end
        end
      end
    end
  end
end
