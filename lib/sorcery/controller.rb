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
      Config.update!
      Config.configure!
    end
    
    module InstanceMethods
      # To be used as before_filter.
      # Will trigger auto-login attempts via the call to logged_in?
      # If all attempts to auto-login fail, the failure callback will be called.
      def require_login
        if !logged_in?
          session[:return_to_url] = request.url if Config.save_return_to_url
          self.send(Config.not_authenticated_action) 
        end
      end
      
      # Takes credentials and returns a user on successful authentication.
      # Runs hooks after login or failed login.
      def login(*credentials)
        user = Config.user_class.authenticate(*credentials)
        if user
          return_to_url = session[:return_to_url]
          reset_session # protect from session fixation attacks
          session[:return_to_url] = return_to_url
          login_user(user)
          after_login!(user, credentials)
          current_user
        else
          after_failed_login!(credentials)
          nil
        end
      end
      
      # Resets the session and runs hooks before and after.
      def logout
        if logged_in?
          before_logout!(current_user)
          reset_session
          after_logout!
        end
      end
      
      def logged_in?
        !!current_user
      end
      
      # attempts to auto-login from the sources defined (session, basic_auth, cookie, etc.)
      # returns the logged in user if found, false if not (using old restful-authentication trick, nil != false).
      def current_user
        @current_user ||= login_from_session || login_from_other_sources unless @current_user == false
      end
      
      # used when a user tries to access a page while logged out, is asked to login, and we want to return him back to the page he originally wanted.
      def redirect_back_or_to(url, flash_hash = {})
        redirect_to(session[:return_to_url] || url, :flash => flash_hash)
      end
      
      # The default action for denying non-authenticated users.
      # You can override this method in your controllers,
      # or provide a different method in the configuration.
      def not_authenticated
        redirect_to root_path
      end
      
      protected
      
      # Tries all available sources (methods) until one doesn't return false.
      def login_from_other_sources
        result = nil
        Config.login_sources.find do |source|
          result = send(source)
        end
        result || false
      end
      
      def login_user(user)
        session[:user_id] = user.id
      end
      
      def login_from_session
        @current_user = (Config.user_class.find_by_id(session[:user_id]) if session[:user_id]) || false
      end
      
      def after_login!(user, credentials)
        Config.after_login.each {|c| self.send(c, user, credentials)}
      end
      
      def after_failed_login!(credentials)
        Config.after_failed_login.each {|c| self.send(c, credentials)}
      end
      
      def before_logout!(user)
        Config.before_logout.each {|c| self.send(c, user)}
      end
      
      def after_logout!
        Config.after_logout.each {|c| self.send(c)}
      end
      
    end
    
    module Config
      class << self
        attr_accessor :submodules,
        
                      :user_class,                    # what class to use as the user class. Set automatically when you call authenticates_with_sorcery! in the User class.
                      
                      :not_authenticated_action,      # what controller action to call for non-authenticated users.
                      
                      :save_return_to_url,            # when a non logged in user tries to enter a page that requires login, save the URL he wanted to reach, 
                                                      # and send him there after login.
                      
                      :login_sources,
                      :after_login,
                      :after_failed_login,
                      :before_logout,
                      :after_logout                      
                      
        def init!
          @defaults = {
            :@user_class                           => nil,
            :@submodules                           => [],
            :@not_authenticated_action             => :not_authenticated,
            :@login_sources                        => [],
            :@after_login                          => [],
            :@after_failed_login                   => [],
            :@before_logout                        => [],
            :@after_logout                         => [],
            :@save_return_to_url                   => true
          }
        end
        
        # Resets all configuration options to their default values.
        def reset!
          @defaults.each do |k,v|
            instance_variable_set(k,v)
          end       
        end
        
        def update!
          @defaults.each do |k,v|
            instance_variable_set(k,v) if !instance_variable_defined?(k)
          end
        end
        
        def user_config(&blk)
          block_given? ? @user_config = blk : @user_config
        end
        
        def configure(&blk)
          @configure_blk = blk
        end
        
        def configure!
          @configure_blk.call(self) if @configure_blk
        end
      end
      init!
      reset!
    end
  end
end