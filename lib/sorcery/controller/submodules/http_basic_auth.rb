module Sorcery
  module Controller
    module Submodules
      # This submodule integrates HTTP Basic authentication into sorcery.
      # You are provided with a before filter, require_login_from_http_basic, 
      # which requests the browser for authentication.
      # Then the rest of the submodule takes care of logging the user in 
      # into the session, so that the next requests will keep him logged in.
      module HttpBasicAuth
        def self.included(base)
          base.send(:include, InstanceMethods)
          Config.module_eval do
            class << self
              attr_accessor :controller_to_realm_map            # What realm to display for which controller name.
                            
              def merge_http_basic_auth_defaults!
                @defaults.merge!(:@controller_to_realm_map  => {"application" => "Application"})
              end
            end
            merge_http_basic_auth_defaults!
          end
          Config.login_sources << :login_from_basic_auth
        end
        
        module InstanceMethods

          protected
          
          # to be used as a before_filter.
          # The method sets a session when requesting the user's credentials.
          # This is a trick to overcome the way HTTP authentication works (explained below):
          #
          # Once the user fills the credentials once, the browser will always send it to the 
          # server when visiting the website, until the browser is closed.
          # This causes wierd behaviour if the user logs out. The session is reset, yet the 
          # user is re-logged in by the before_filter calling 'login_from_basic_auth'.
          # To overcome this, we set a session when requesting the password, which logout will
          # reset, and that's how we know if we need to request for HTTP auth again.
          def require_login_from_http_basic
            (request_http_basic_authentication(realm_name_by_controller) and (session[:http_authentication_used] = true) and return) if (request.authorization.nil? || session[:http_authentication_used].nil?)
            require_login
            session[:http_authentication_used] = nil unless logged_in?
          end
          
          # given to main controller module as a login source callback
          def login_from_basic_auth
            authenticate_with_http_basic do |username, password|
              @current_user = (user_class.authenticate(username, password) if session[:http_authentication_used]) || false
              auto_login(@current_user) if @current_user
              @current_user
            end
          end
          
          # Sets the realm name by searching the controller name in the hash given at configuration time.
          def realm_name_by_controller
            if defined?(ActionController::Base)
              current_controller = self.class
              while current_controller != ActionController::Base
                result = Config.controller_to_realm_map[current_controller.controller_name]
                return result if result
                current_controller = current_controller.superclass
              end
              nil
            else
              Config.controller_to_realm_map["application"]
            end
          end
          
        end

      end
    end
  end
end