module SimpleAuth
  module Controller
    def self.included(klass)
      klass.class_eval do
        extend ClassMethods
      end
    end
    
    module ClassMethods
      def activate_simple_auth!
        yield Config if block_given?
        
        self.class_eval do
          def login(username,password)
            user = User.authentic?(username,password)
            if user
              reset_session # protect from session fixation attacks
              session[:user_id] = user.id
              user
            end
          end
          
          def logout
            if logged_in?
              reset_session
            end
          end
          
          def logged_in?
            session[:user_id]
          end
        end
      end
    end
    
    module Config
      class << self
        attr_accessor :session_attribute_name
        
        def reset_to_defaults!
          @session_attribute_name = :session
        end
      
      end
      reset_to_defaults!
    end
  end
end