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
        end
        
        module InstanceMethods
          # To be used as a before_filter, before authenticate
          def timeout_session
            if session[:last_login] && Time.now.utc - session[:last_login] > Config.session_timeout
              reset_session
              @logged_in_user = false
            end
          end
        end
      end
    end
  end
end
