module Sorcery
  module TestHelpers
    SUBMODUELS_AUTO_ADDED_CONTROLLER_FILTERS = [:register_last_activity_time_to_db, :deny_banned_user, :validate_session]

    def create_new_user(attributes_hash = nil)
      user_attributes_hash = attributes_hash || {:username => 'gizmo', :email => "bla@bla.com", :password => 'secret'}
      @user = User.new(user_attributes_hash)
      @user.save!
      @user
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

      User.activate_sorcery! do |config|
        options.each do |property,value|
          config.send(:"#{property}=", value)
        end
      end
    end

    def sorcery_model_property_set(property, *values)
      User.class_eval do
        sorcery_config.send(:"#{property}=", *values)
      end
    end

    def sorcery_controller_property_set(property, value)
      ApplicationController.activate_sorcery! do |config|
        config.send(:"#{property}=", value)
      end
    end
    
    def sorcery_controller_oauth_property_set(provider, property, value)
      ApplicationController.activate_sorcery! do |config|
        config.send(provider).send(:"#{property}=", value)
      end
    end

    private

    # reload user class between specs
    # so it will be possible to test the different submodules in isolation
    def reload_user_class
      Object.send(:remove_const,:User)
      load 'user.rb'
    end
  end
end