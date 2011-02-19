module Sorcery
  module Controller
    module Submodules
      # The Remember Me submodule takes care of setting the user's cookie so that he will be automatically logged in to the site on every visit,
      # until the cookie expires.
      # See Sorcery::Model::Submodules::RememberMe for configuration options.
      module RememberMe
        def self.included(base)
          base.send(:include, InstanceMethods)
          Config.login_sources << :login_from_cookie
          Config.after_login << :remember_me_if_asked_to
          Config.after_logout << :forget_me!
        end
        
        module InstanceMethods
          # This method sets the cookie and calls the user to save the token and the expiration to db.
          def remember_me!
            logged_in_user.remember_me!
            cookies[:remember_me_token] = { :value => logged_in_user.remember_me_token, :expires => logged_in_user.remember_me_token_expires_at }        
          end

          # Clears the cookie and clears the token from the db.
          def forget_me!
            logged_in_user.forget_me!
            cookies[:remember_me_token] = nil
          end
          
          protected
          
          # calls remember_me! if a third credential was passed to the login method.
          # Runs as a hook after login.
          def remember_me_if_asked_to(user, credentials)
            remember_me! if credentials.size == 3 && credentials[2]
          end
          
          # Checks the cookie for a remember me token, tried to find a user with that token and logs the user in if found.
          # Runs as a login source. See 'logged_in_user' method for how it is used.
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