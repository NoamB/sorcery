module SimpleAuth
  # This module handles all plugin operations which are related to the Model layer in the MVC pattern.
  # It should be included into the ORM base class.
  # In the case of Rails this is usually ActiveRecord (actually, in that case, the plugin does this automatically).
  #
  # When included it defines a single method: 'activate_simple_auth!' which when called adds the other capabilities to the class.
  # This method is also the place to configure the plugin in the Model layer.
  module Model
    def self.included(klass)
      klass.class_eval do
        class << self
          def activate_simple_auth!
            @simple_auth_config = Config.new
            self.class_eval do
              extend ClassMethods # included here, before submodules, so they can be overriden by them.
              include InstanceMethods
              @simple_auth_config.submodules = ::SimpleAuth::Controller::Config.submodules
              @simple_auth_config.submodules.each do |mod|
                include Submodules.const_get(mod.to_s.split("_").map {|p| p.capitalize}.join(""))
              end
            end
            
            yield @simple_auth_config if block_given?

            @simple_auth_config.post_config_validations.each { |pcv| pcv.call(@simple_auth_config) }
            
            self.class_eval do
              include Adapters::ActiveRecord if defined?(ActiveRecord) && self.ancestors.include?(ActiveRecord::Base)
            end
          end
        end
      end
    end
    
    module InstanceMethods
      # Returns the class instance variable for configuration, when called by an instance.
      def simple_auth_config
        self.class.simple_auth_config
      end
    end
    
    module ClassMethods
      # Returns the class instance variable for configuration, when called by the class itself.
      def simple_auth_config
        @simple_auth_config
      end
      
      # The default authentication method.
      # Takes a username and password,
      # Finds the user by the username and compares the user's password to the one supplied to the method.
      # returns the user if success, nil otherwise.
      def authenticate(username, password)
        user = where("#{@simple_auth_config.username_attribute_name} = ?", username).first
        user if user && @simple_auth_config.pre_authenticate_validations.all? {|proc| proc.call(user, @simple_auth_config)} && (user.send(@simple_auth_config.password_attribute_name) == password)
      end
    end

    # Each class which calls 'activate_simple_auth!' receives an instance of this class.
    # This enables two different classes to use this plugin with different configurations.
    # Every submodule which gets loaded may add accessors to this class so that all options will be configure from a single place.
    class Config
      attr_accessor :submodules,
                    :username_attribute_name, 
                    :password_attribute_name,
                    :email_attribute_name
      
      attr_reader   :post_config_validations,
                    :pre_authenticate_validations
      
      def initialize
        @post_config_validations = []
        @pre_authenticate_validations = []
        @defaults = {
          :@username_attribute_name              => :username,
          :@password_attribute_name              => :password,
          :@email_attribute_name                 => :email
        }
        reset!
      end     
           
      # Resets all configuration options to their default values.
      def reset!
        @defaults.each do |k,v|
          instance_variable_set(k,v)
        end       
      end
      
      # Here submodules can add procs that will run after the user configuration params are set.
      def add_post_config_validation(proc)
        @post_config_validations << proc
      end
      
      def add_pre_authenticate_validation(proc)
        @pre_authenticate_validations << proc
      end
    end
    
  end
end