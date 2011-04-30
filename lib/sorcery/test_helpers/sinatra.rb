module Sorcery
  module TestHelpers
    module Sinatra
      def self.included(base)
        base.send(:include, InstanceMethods)
        base.send(:include, CookieSessionMethods)
        ::Sinatra::Base.class_eval do
          class << self
            attr_accessor :rack_test_session
          end

          def self.inherited(subclass)
            super
            subclass.class_eval do
              class << self
                attr_accessor :rack_test_session
              end
            end
          end

          include CookieSessionMethods

          def rack_test_session
            self.class.rack_test_session
          end
        end
      end

      module InstanceMethods
        def get_sinatra_app(app)
          while !app.kind_of? ::Sinatra::Base do
            app = app.instance_variable_get(:@app)
          end
          app
        end

        def login_user(user=nil)
          user ||= @user
          get_sinatra_app(app).send(:login_user, user)
          get_sinatra_app(app).send(:after_login!, user, [user.send(user.sorcery_config.username_attribute_name), 'secret'])
        end

        def logout_user
          get_sinatra_app(app).send(:logout)
        end
      end

      module CookieSessionMethods
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

          def clear
            @data = {}
          end
        end

        def session
          SessionData.new(cookies)
        end

        def cookies
          rack_test_session.instance_variable_get(:@rack_mock_session).cookie_jar
        end
      end
    end
  end
end