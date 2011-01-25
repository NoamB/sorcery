module Sorcery
  module Controller
    def self.included(klass)
      klass.class_eval do
        extend ClassMethods
      end
    end
    
    module ClassMethods
      def activate_sorcery!(*submodules)
        Config.submodules = submodules
        yield Config if block_given?
        
        self.class_eval do
          include InstanceMethods
          include RememberMeMethods if Config.submodules.include?(:remember_me)
          helper_method :logged_in_user
        end
      end
    end
    
    module InstanceMethods
      def authenticate
        if !logged_in?
          self.send(Config.not_logged_in_action)
        end
      end
      
      def login(user)
        config = user.sorcery_config
        user = Config.user_class.authenticate(user.send(config.username_attribute_name), user.send(config.password_attribute_name))
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
        !!logged_in_user
      end
      
      def logged_in_user
        @logged_in_user ||= login_from_session || login_from_cookie unless @logged_in_user == false # || login_from_basic_auth || )
      end
      
      protected
      
      def login_from_session
        @logged_in_user = (Config.user_class.find_by_id(session[:user_id]) if session[:user_id]) || false
      end
      
      def login_from_cookie
        user = send(:"#{Config.cookies_attribute_name}")[:remember_me_token] && Config.user_class.find_by_remember_me_token(send(:"#{Config.cookies_attribute_name}")[:remember_me_token])
        if user && user.remember_me_token?
          send(:"#{Config.cookies_attribute_name}")[:remember_me_token] = { :value => user.remember_token, :expires => user.remember_token_expires_at }
          @logged_in_user = user
        else
          @logged_in_user = false
        end
      end
    end
    
    module RememberMeMethods
      def remember_me!
        logged_in_user.remember_me!
        send(:"#{Config.cookies_attribute_name}")[:remember_me_token] = { :value => logged_in_user.remember_me_token, :expires => logged_in_user.remember_me_token_expires_at }        
      end
      
      def forget_me!
        logged_in_user.forget_me!
        send(:"#{Config.cookies_attribute_name}")[:remember_me_token] = nil
      end
    end
    
    module Config
      class << self
        attr_accessor :user_class,
                      :submodules,
                      :session_attribute_name,
                      :cookies_attribute_name,
                      :not_logged_in_action
        
        def reset!
          @user_class = User
          @session_attribute_name = :session
          @cookies_attribute_name = :cookies
          @not_logged_in_action = :access_denied
        end
      
      end
      reset!
    end
  end
end