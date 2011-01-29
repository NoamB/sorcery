module Sorcery
  module Controller
    module Submodules
      module RememberMe
        def self.included(base)
          base.send(:include, InstanceMethods)
          Config.login_sources << :login_from_cookie
          Config.after_login << :remember_me!
          Config.after_logout << :forget_me!
        end
        
        module InstanceMethods
          def remember_me!
            logged_in_user.remember_me!
            send(:"#{Config.cookies_attribute_name}")[:remember_me_token] = { :value => logged_in_user.remember_me_token, :expires => logged_in_user.remember_me_token_expires_at }        
          end

          def forget_me!
            logged_in_user.forget_me!
            send(:"#{Config.cookies_attribute_name}")[:remember_me_token] = nil
          end

          protected

          def login_from_cookie
            user = send(:"#{Config.cookies_attribute_name}")[:remember_me_token] && Config.user_class.find_by_remember_me_token(send(:"#{Config.cookies_attribute_name}")[:remember_me_token])
            if user && user.remember_me_token?
              send(:"#{Config.cookies_attribute_name}")[:remember_me_token] = { :value => user.remember_me_token, :expires => user.remember_me_token_expires_at }
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