require 'sorcery'
require 'rails'

module Sorcery
  # The Sorcery engine takes care of extending ActiveRecord (if used) and ActionController,
  # With the plugin logic.
  # ActionController is also automatically activated with the plugin to save you the trouble.
  class Engine < Rails::Engine  
    initializer "extend Model with sorcery" do |app|
      ActiveRecord::Base.send(:include, Sorcery::Model) if defined?(ActiveRecord)
    end
    
    initializer "extend Controller with sorcery" do |app|
      ActionController::Base.send(:include, Sorcery::Controller)
      ActionController::Base.activate_sorcery!
    end
  end
end