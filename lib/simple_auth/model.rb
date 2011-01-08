module SimpleAuth
  module Model
    def self.included(klass)
      klass.class_eval do
        class << self
          def activate_simple_auth!(*submodules)
            @simple_auth_config = Config.new
            @simple_auth_config.submodules = submodules
            self.class_eval do
              extend ClassMethods # included here to be overriden by submodules
              include InstanceMethods
              submodules.each do |mod|
                include Submodules.const_get(mod.to_s.split("_").map {|p| p.capitalize}.join(""))
              end
            end

            yield @config if block_given?

            self.class_eval do
              include Adapters::ActiveRecord if defined?(ActiveRecord) && self.ancestors.include?(ActiveRecord::Base)
            end
          end
        end
      end
    end
    
    module InstanceMethods
      def simple_auth_config
        self.class.simple_auth_config
      end
    end
    
    module ClassMethods
      def simple_auth_config
        @simple_auth_config
      end
      
      def authenticate(username, password)
        user = where("#{@simple_auth_config.username_attribute_name} = ?", username).first
        user if user && (user.send(@simple_auth_config.password_attribute_name) == password)
      end
    end

    # Each class which calls 'activate_simple_auth!' receives an instance of this class.
    # This enables two different classes to use this plugin with different configurations.
    class Config
      attr_accessor :submodules,
                    :username_attribute_name, 
                    :password_attribute_name
      
      def initialize
        @defaults = {
          :@username_attribute_name              => :username,
          :@password_attribute_name              => :password
        }
        reset!
      end     
            
      def reset!
        @defaults.each do |k,v|
          instance_variable_set(k,v)
        end       
      end
    end
    
  end
end