module Sorcery
  module Controller
    def self.included(klass)
      klass.class_eval do
        include InstanceMethods
        Config.submodules.each do |mod|
          begin
            include Submodules.const_get(mod.to_s.split("_").map {|p| p.capitalize}.join("")) 
          rescue NameError
            # don't stop on a missing submodule.
          end
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
          reset_session # protect from session fixation attacks
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
        session[:user_id] = user.id
        session[:last_login] = Time.now.utc
      end
      
      def login_from_session
        @logged_in_user = (Config.user_class.find_by_id(session[:user_id]) if session[:user_id]) || false
      end
      
      def after_login!
        Config.after_login.each {|c| self.send(c)}
      end
      
      def after_logout!
        Config.after_logout.each {|c| self.send(c)}
      end
    end
    
    module Config
      class << self
        attr_accessor :user_class,
                      :submodules,
                      :session_attribute_name,
                      :cookies_attribute_name,
                      :not_authenticated_action,
                      :login_sources,
                      :after_login,
                      :after_logout
                      
        def init!
          @defaults = {
            :@user_class                           => nil,
            :@submodules                           => [],
            :@session_attribute_name               => :session,
            :@cookies_attribute_name               => :cookies,
            :@not_authenticated_action             => :not_authenticated,
            :@login_sources                        => [],
            :@after_login                          => [],
            :@after_logout                         => []
          }
        end
        
        # Resets all configuration options to their default values.
        def reset!
          @defaults.each do |k,v|
            instance_variable_set(k,v)
          end       
        end
      end
      init!
      reset!
    end
  end
end