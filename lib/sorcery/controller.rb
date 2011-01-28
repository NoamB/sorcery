module Sorcery
  module Controller
    def self.included(klass)
      klass.class_eval do
        include InstanceMethods
        if Config.submodules.include?(:remember_me)
          include RememberMeMethods
          Config.login_sources << :login_from_cookie
          remember_me_proc = Proc.new do |user,controller|
            controller.remember_me!
          end
          Config.after_login(remember_me_proc)
          
          forget_me_proc = Proc.new do |user,controller|
            controller.forget_me!
          end
          Config.after_logout(forget_me_proc)
        end
      end
    end
    
    module InstanceMethods
      # To be used as before_filter.
      # Will trigger auto-login attempts via the call to logged_in?
      # If all attempts to auto-login fail, the failure callback will be called.
      def authenticate
        self.send(Config.not_authenticated_action) if !logged_in?
      end
      
      def login(*credentials)
        user = Config.user_class.authenticate(*credentials)
        if user
          login_user(user)
          after_login!
          logged_in_user
        end
      end
      
      def logout
        if logged_in?
          reset_session
          after_logout!
        end
      end
      
      def logged_in?
        !!logged_in_user
      end
      
      # attempts to auto-login from the sources defined (session, basic_auth, cookie, etc.)
      # returns the logged in user if found, false if not (using old restful-authentication trick).
      def logged_in_user
        @logged_in_user ||= login_from_session || login_from_other_sources unless @logged_in_user == false # || login_from_basic_auth || )
      end
      
      def login_from_other_sources
        result = nil
        Config.login_sources.find do |source|
          result = send(source)
        end
        result || false
      end
      
      protected
      
      def login_user(user)
        reset_session # protect from session fixation attacks
        session[:user_id] = user.id
      end
      
      def login_from_session
        @logged_in_user = (Config.user_class.find_by_id(session[:user_id]) if session[:user_id]) || false
      end
      
      def after_login!
        Config.after_login_callbacks.each {|c| c.call(logged_in_user,self)}
      end
      
      def after_logout!
        Config.after_logout_callbacks.each {|c| c.call(logged_in_user,self)}
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
    
    module Config
      class << self
        attr_accessor :user_class,
                      :submodules,
                      :session_attribute_name,
                      :cookies_attribute_name,
                      :not_authenticated_action,
                      :login_sources
        
        attr_reader   :after_login_callbacks,
                      :after_logout_callbacks
        
        def reset!
          @user_class = nil
          @submodules = []
          @session_attribute_name = :session
          @cookies_attribute_name = :cookies
          @not_authenticated_action = :not_authenticated
          @login_sources = []
          @after_login_callbacks = []
          @after_logout_callbacks = []
        end
        
        def after_login(proc)
          @after_login_callbacks << proc
        end
        
        def after_logout(proc)
          @after_logout_callbacks << proc
        end
      end
      reset!
    end
  end
end