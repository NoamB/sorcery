module Sorcery
  module Controller
    module Submodules
      module HttpBasicAuth
        def self.included(base)
          base.send(:include, InstanceMethods)
          Config.login_sources << :login_from_basic_auth
        end
        
        module InstanceMethods

          # to be used as a before_filter.
          # The method sets a session when requesting the user's credentials.
          # This is a trick to overcome the way HTTP authentication work (explained below):
          #
          # Once the user fills the credentials once, the browser will always send it to the server when visiting the website, until the browser is closed.
          # This causes wierd behaviour if the user logs out. The session is reset, yet the user is re-logged in by the before_filter calling 'login_from_basic_auth'.
          # To overcome this, we set a session when requesting the password, which logout will reset, and that's how we know if we need to request for HTTP auth again.
          def require_user_login_from_http
            request_http_basic_authentication and (session[:http_authentication_used] = true) and return if request.authorization.nil? || session[:http_authentication_used].nil?
            require_user_login
          end
          
          protected
          
          def login_from_basic_auth
            authenticate_with_http_basic do |username, password|
              @logged_in_user = (Config.user_class.authenticate(username, password) if session[:http_authentication_used]) || false
            end
          end
          
        end

      end
    end
  end
end