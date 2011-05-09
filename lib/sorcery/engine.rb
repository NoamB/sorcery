require 'sorcery'
require 'rails'

module Sorcery
  # The Sorcery engine takes care of extending ActiveRecord (if used) and ActionController,
  # With the plugin logic.
  class Engine < Rails::Engine
    config.sorcery = ::Sorcery::Controller::Config
    
    initializer "extend Model with sorcery" do |app|
      ActiveRecord::Base.send(:include, Sorcery::Model) if defined?(ActiveRecord)
      Mongoid::Document.module_eval do
        included do
          attr_reader :new_record
          include Sorcery::Model::Adapters::Mongoid
          include Sorcery::Model
        end
      end if defined?(Mongoid)
          
    end
    
    initializer "extend Controller with sorcery" do |app|
      ActionController::Base.send(:include, Sorcery::Controller)
      ActionController::Base.helper_method :current_user
    end
    
    initializer "attempt to preload user model" do |app|
      begin
        require Rails.root + "app/models/user.rb"
      rescue LoadError
      end
    end
    
    rake_tasks do
      load "sorcery/railties/tasks.rake"
    end
    
  end
end