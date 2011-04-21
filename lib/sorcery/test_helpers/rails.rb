module Sorcery
  module TestHelpers
    module Rails
      SUBMODUELS_AUTO_ADDED_CONTROLLER_FILTERS = [:register_last_activity_time_to_db, :deny_banned_user, :validate_session]
      
      def sorcery_reload!(submodules = [], options = {})
        reload_user_class

        # return to no-module configuration
        ::Sorcery::Controller::Config.init!
        ::Sorcery::Controller::Config.reset!

        # remove all plugin before_filters so they won't fail other tests.
        # I don't like this way, but I didn't find another.
        # hopefully it won't break until Rails 4.
        ApplicationController._process_action_callbacks.delete_if {|c| SUBMODUELS_AUTO_ADDED_CONTROLLER_FILTERS.include?(c.filter) }

        # configure
        ::Sorcery::Controller::Config.submodules = submodules
        ::Sorcery::Controller::Config.user_class = nil
        ActionController::Base.send(:include,::Sorcery::Controller)

        ::Sorcery::Controller::Config.user_config do |user|
          options.each do |property,value|
            user.send(:"#{property}=", value)
          end
        end
        User.authenticates_with_sorcery!
      end
      
      def sorcery_controller_property_set(property, value)
        ::Sorcery::Controller::Config.send(:"#{property}=", value)
      end

      def sorcery_controller_external_property_set(provider, property, value)
        ::Sorcery::Controller::Config.send(provider).send(:"#{property}=", value)
      end
      
      def login_user(user = nil)
        user ||= @user
        subject.send(:login_user,user)
        subject.send(:after_login!,user,[user.username,'secret'])
      end

      def logout_user
        subject.send(:logout)
      end

      def clear_user_without_logout
        subject.instance_variable_set(:@current_user,nil)
      end
    end
  end
end
