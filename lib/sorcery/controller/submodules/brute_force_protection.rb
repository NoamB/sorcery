module Sorcery
  module Controller
    module Submodules
      module BruteForceProtection
        def self.included(base)
          base.send(:include, InstanceMethods)
          Config.module_eval do
            class << self
              attr_accessor :login_retries_amount_allowed,
                            :login_retries_time_period,
                            :login_ban_time_period,
                            :banned_action
                            
              def merge_brute_force_protection_defaults!
                @defaults.merge!(:@login_retries_amount_allowed  => 50,
                                 :@login_retries_time_period     => 30,
                                 :@login_ban_time_period         => 3600,
                                 :@banned_action                 => :default_banned_action)
              end
            end
            merge_brute_force_protection_defaults!
          end
          Config.after_failed_login << :check_failed_logins_limit_reached
          base.prepend_before_filter :deny_banned_user
        end
        
        module InstanceMethods
          def check_failed_logins_limit_reached(user, credentials)
            now = Time.now.utc
              
            # not banned
            if session[:first_failed_login_time]
              reset_failed_logins_if_time_passed(now)
            else
              session[:first_failed_login_time] = now
            end
            increment_failed_logins
            # ban
            ban_if_above_limit(now)
          end
          
          protected
          
          def release_ban_if_time_passed(now)
            if now - session[:ban_start_time] > Config.login_ban_time_period
              session[:banned] = nil
              session[:failed_logins] = 0
              return true
            end
            false
          end
          
          def increment_failed_logins
            session[:failed_logins] ||= 0
            session[:failed_logins] += 1
          end
          
          def reset_failed_logins_if_time_passed(now)
            if now - session[:first_failed_login_time] > Config.login_retries_time_period
              session[:failed_logins] = 0 
              session[:first_failed_login_time] = now
            end
          end
          
          def ban_if_above_limit(now)
            if session[:failed_logins] > Config.login_retries_amount_allowed
              session[:banned] = true
              session[:ban_start_time] = now
            end
          end
          
          def deny_banned_user
            if session[:banned]
              now = Time.now.utc
              release_ban_if_time_passed(now)
            end
            
            # if still banned
            send(Config.banned_action) if session[:banned]
          end
          
          def default_banned_action
            render :nothing => true
          end
        end
      end
    end
  end
end