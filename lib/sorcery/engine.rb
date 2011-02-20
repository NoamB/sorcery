require 'sorcery'
require 'rails'

module Sorcery
  # The Sorcery engine takes care of extending ActiveRecord (if used) and ActionController,
  # With the plugin logic.
  class Engine < Rails::Engine
    config.sorcery = ::Sorcery::Controller::Config
    
    initializer "extend Model with sorcery" do |app|
      ActiveRecord::Base.send(:include, Sorcery::Model) if defined?(ActiveRecord)
    end
    
    initializer "extend Controller with sorcery" do |app|
      ActionController::Base.send(:include, Sorcery::Controller)
      ActionController::Base.helper_method :logged_in_user
    end
    
    initializer "preload all models, needed for detection of the User class." do |app|
      Dir[Rails.root + 'app/models/**/*.rb'].each do |path|
        require path
      end unless ::Sorcery::Controller::Config.user_class
    end
  end
end