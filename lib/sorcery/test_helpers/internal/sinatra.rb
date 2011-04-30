module Sorcery
  module TestHelpers
    module Internal
      module Sinatra

        class ::Sinatra::Application
          class << self
            attr_accessor :sorcery_vars
          end
          @sorcery_vars = {}

          # NOTE: see before and after test filters in filters.rb

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

        def login_user(user=nil)
          user ||= @user
          get_sinatra_app(subject).send(:login_user,user)
          get_sinatra_app(subject).send(:after_login!,user,[user.username,'secret'])
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

        def cookies
          rack_test_session.instance_variable_get(:@rack_mock_session).cookie_jar
        end

        def sorcery_reload!(submodules = [], options = {})
          reload_user_class

          # return to no-module configuration
          ::Sorcery::Controller::Config.init!
          ::Sorcery::Controller::Config.reset!

          # clear all filters
          ::Sinatra::Application.instance_variable_set(:@filters,{:before => [],:after => []})
          ::Sinatra::Application.class_eval do
            load File.join(File.dirname(__FILE__),'..','..','..','..','spec','sinatra','filters.rb')
          end

          # configure
          ::Sorcery::Controller::Config.submodules = submodules
          ::Sorcery::Controller::Config.user_class = nil
          ::Sinatra::Application.send(:include, Sorcery::Controller::Adapters::Sinatra)
          ::Sinatra::Application.send(:include, Sorcery::Controller)

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
      end
    end
  end
end