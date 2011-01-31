module Sorcery
  module Controller
    module Submodules
      module RememberMe
        def self.included(base)
          base.send(:include, InstanceMethods)
          Config.login_sources << :login_from_cookie
          Config.after_login << :remember_me_if_asked_to
          Config.after_logout << :forget_me!
        end
        
        module InstanceMethods
          def remember_me!
            logged_in_user.remember_me!
            cookies[:remember_me_token] = { :value => logged_in_user.remember_me_token, :expires => logged_in_user.remember_me_token_expires_at }        
          end

          def forget_me!
            logged_in_user.forget_me!
            cookies[:remember_me_token] = nil
          end
          
          protected
          
          def remember_me_if_asked_to(user, credentials)
            remember_me! if credentials.size == 3 && credentials[2]
          end
          
          def login_from_cookie
            user = cookies[:remember_me_token] && Config.user_class.find_by_remember_me_token(cookies[:remember_me_token])
            if user && user.remember_me_token?
              cookies[:remember_me_token] = { :value => user.remember_me_token, :expires => user.remember_me_token_expires_at }
              @logged_in_user = user
            else
              @logged_in_user = false
            end
          end
        end

      end
    end
  end
end