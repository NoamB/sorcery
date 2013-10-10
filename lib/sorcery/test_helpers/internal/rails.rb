module Sorcery
  module TestHelpers
    module Internal
      module Rails
        include ::Sorcery::TestHelpers::Rails

        SUBMODUELS_AUTO_ADDED_CONTROLLER_FILTERS = [
          :register_last_activity_time_to_db,
          :deny_banned_user,
          :validate_session
        ]

        def sorcery_reload!(submodules = [], options = {})
          reload_user_class

          # return to no-module configuration
          ::Sorcery::Controller::Config.init!
          ::Sorcery::Controller::Config.reset!

          # remove all plugin before_filters so they won't fail other tests.
          # I don't like this way, but I didn't find another.
          # hopefully it won't break until Rails 4.
          SorceryController._process_action_callbacks.delete_if {|c| SUBMODUELS_AUTO_ADDED_CONTROLLER_FILTERS.include?(c.filter) }

          # configure
          ::Sorcery::Controller::Config.submodules = submodules
          ::Sorcery::Controller::Config.user_class = nil
          ActionController::Base.send(:include,::Sorcery::Controller)
          ::Sorcery::Controller::Config.user_class = "User"

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

        # This helper is used to fake multiple users signing in in tests.
        # It does so by clearing @current_user, thus allowing a new user to login,
        # all this without calling the :logout action explicitly.
        # A dirty dirty hack.
        def clear_user_without_logout
          subject.instance_variable_set(:@current_user,nil)
        end
      end
    end
  end
end
