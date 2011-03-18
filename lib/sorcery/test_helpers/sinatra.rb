module Sorcery
  module TestHelpers
    module Sinatra
      
      class MyApp
        class << self
          def new
            return this
          end
        end
      end
      
      class ::Sinatra::Application
        class << self
          attr_accessor :sorcery_vars, :sorcery_cookies, :sorcery_instance
        end
        @sorcery_vars = {}
        @sorcery_cookies = {}

        before do
          self.class.sorcery_vars = {}
          self.class.sorcery_cookies = {}
          self.class.sorcery_instance = self
        end
        
        after do
          save_instance_vars
          self.class.sorcery_cookies = response.cookies
        end
      end
              
      def save_instance_vars
        instance_variables.each do |var|
          self.class.sorcery_vars[:"#{var.to_s.delete("@")}"] = instance_variable_get(var)
        end
      end
      
      ::RSpec::Matchers.define :redirect_to do |expected|
        match do |actual|
          actual.status == 302 && actual.location == expected
        end
      end
      
      def get_sinatra_app(app)
        while app.class != ::Sinatra::Application do
          app = app.instance_variable_get(:@app)
        end
        app
      end
        
      def this
        ::Sinatra::Application.sorcery_instance
      end
      
      def assigns
        ::Sinatra::Application.sorcery_vars
      end
      
      def cookies
        ::Sinatra::Application.sorcery_cookies
      end
      
      def sorcery_reload!(submodules = [], options = {})
        reload_user_class

        # return to no-module configuration
        ::Sorcery::Controller::Config.init!
        ::Sorcery::Controller::Config.reset!

        # configure
        ::Sorcery::Controller::Config.submodules = submodules
        ::Sorcery::Controller::Config.user_class = nil
        Sinatra::Application.send(:include, Sorcery::Controller)
        
        User.activate_sorcery! do |config|
          options.each do |property,value|
            config.send(:"#{property}=", value)
          end
        end
      end
      
      def sorcery_controller_property_set(property, value)
        ::Sinatra::Application.activate_sorcery! do |config|
          config.send(:"#{property}=", value)
        end
      end

      def sorcery_controller_oauth_property_set(provider, property, value)
        ::Sinatra::Application.activate_sorcery! do |config|
          config.send(provider).send(:"#{property}=", value)
        end
      end
    end
  end
end