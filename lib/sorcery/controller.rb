module Sorcery
  module Controller
    def self.included(klass)
      klass.class_eval do
        include InstanceMethods
        Config.submodules.each do |mod|
          begin
            include Submodules.const_get(mod.to_s.split('_').map { |p| p.capitalize }.join)
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
          session[:return_to_url] = request.url if Config.save_return_to_url && request.get?
          self.send(Config.not_authenticated_action)
        end
      end

      # Takes credentials and returns a user on successful authentication.
      # Runs hooks after login or failed login.
      def login(*credentials)
        @current_user = nil
        user = user_class.authenticate(*credentials)
        if user
          old_session = session.dup.to_hash
          reset_sorcery_session
          old_session.each_pair do |k,v|
            session[k.to_sym] = v
          end
          form_authenticity_token

          auto_login(user)
          after_login!(user, credentials)
          current_user
        else
          after_failed_login!(credentials)
          nil
        end
      end

      # put this into the catch block to rescue undefined method `destroy_session'
      # hotfix for https://github.com/NoamB/sorcery/issues/464
      # can be removed when Rails 4.1 is out
      def reset_sorcery_session
        reset_session # protect from session fixation attacks
      rescue NoMethodError
      end

      # Resets the session and runs hooks before and after.
      def logout
        if logged_in?
          @current_user = current_user if @current_user.nil?
          before_logout!(@current_user)
          reset_sorcery_session
          after_logout!
          @current_user = nil
        end
      end

      def logged_in?
        !!current_user
      end

      # attempts to auto-login from the sources defined (session, basic_auth, cookie, etc.)
      # returns the logged in user if found, nil if not
      def current_user
        unless defined?(@current_user)
          @current_user = login_from_session || login_from_other_sources || nil
        end
        @current_user
      end

      def current_user=(user)
        @current_user = user
      end

      # used when a user tries to access a page while logged out, is asked to login,
      # and we want to return him back to the page he originally wanted.
      def redirect_back_or_to(url, flash_hash = {})
        redirect_to(session[:return_to_url] || url, :flash => flash_hash)
        session[:return_to_url] = nil
      end

      # The default action for denying non-authenticated users.
      # You can override this method in your controllers,
      # or provide a different method in the configuration.
      def not_authenticated
        redirect_to root_path
      end

      # login a user instance
      #
      # @param [<User-Model>] user the user instance.
      # @return - do not depend on the return value.
      def auto_login(user, should_remember = false)
        session[:user_id] = user.id.to_s
        @current_user = user
      end

      # Overwrite Rails' handle unverified request
      def handle_unverified_request
        cookies[:remember_me_token] = nil
        @current_user = nil
        super # call the default behaviour which resets the session
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

      def login_from_session
        @current_user = if session[:user_id]
                          user_class.sorcery_adapter.find_by_id(session[:user_id])
                        end
      end

      def after_login!(user, credentials = [])
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

      def user_class
        @user_class ||= Config.user_class.to_s.constantize
      end

    end

	end
end
