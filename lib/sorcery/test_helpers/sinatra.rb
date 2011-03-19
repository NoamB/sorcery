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
          attr_accessor :sorcery_vars
        end
        @sorcery_vars = {}

        before do
          self.class.sorcery_vars = {}
        end
        
        after do
          save_instance_vars
        end
        
        def save_instance_vars
          instance_variables.each do |var|
            self.class.sorcery_vars[:"#{var.to_s.delete("@")}"] = instance_variable_get(var)
          end
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

      def logout_user
        get_sinatra_app(subject).send(:logout)
      end

      def clear_user_without_logout
        get_sinatra_app(subject).instance_variable_set(:@current_user,nil)
      end
        
      def assigns
        ::Sinatra::Application.sorcery_vars
      end
      
      class SessionData
        def initialize(cookies)
          @cookies = cookies
          @data = cookies['rack.session']
          if @data
            @data = @data.unpack("m*").first
            @data = Marshal.load(@data)
          else
            @data = {}
          end
        end

        def [](key)
          @data[key]
        end

        def []=(key, value)
          @data[key] = value
          session_data = Marshal.dump(@data)
          session_data = [session_data].pack("m*")
          @cookies.merge("rack.session=#{Rack::Utils.escape(session_data)}", URI.parse("//example.org//"))
          raise "session variable not set" unless @cookies['rack.session'] == session_data
        end
      end

      def session
        SessionData.new(rack_test_session.instance_variable_get(:@rack_mock_session).cookie_jar)
      end
      
      def login_user(user=nil)
        user ||= @user
        session[:user_id] = user.id
      end
      
      def sorcery_reload!(submodules = [], options = {})
        reload_user_class

        # return to no-module configuration
        ::Sorcery::Controller::Config.init!
        ::Sorcery::Controller::Config.reset!

        # configure
        ::Sorcery::Controller::Config.submodules = submodules
        ::Sorcery::Controller::Config.user_class = nil
        ::Sinatra::Application.send(:include, Sorcery::Controller::Adapters::Sinatra)
        ::Sinatra::Application.send(:include, Sorcery::Controller)
        
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