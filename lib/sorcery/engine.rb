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
      ApplicationController.send(:include, Sorcery::Controller)
      ApplicationController.helper_method :logged_in_user
    end

  end
end