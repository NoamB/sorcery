module Sorcery
  module TestHelpers
    module Rails
      # logins a user and calls all callbacks
      # accepts a hash with options to facilitate integration testing with Capybara
      #
      # --:integration  (set to true to simulate login/out with http requests)
      # --:login_route  (route to log in a user, defaults to sessions_url link helper 
      # --:logout_route (route to log out a user, defaults to logout_url link_helper (named route mapped to GET sessions#destroy)
      
      def login_user(user = nil, test_context = {})
        user ||= @user
        
        if test_context[:integration]
          simulate_login(user.send(user.sorcery_config.username_attribute_names.first), 'secret', test_context[:login_route])
        else
          @controller.send(:auto_login, user)
          @controller.send(:after_login!, user, [user.send(user.sorcery_config.username_attribute_names.first), 'secret'])
        end
      end

      def logout_user(test_context = {})
        if test_context[:integration]
          simulate_logout(test_context[:logout_route])
        else
          @controller.send(:logout)
        end
      end
            
      private
      
        def simulate_login(user, password, login_route = nil)
          login_route ||= sessions_url
          page.driver.post(login_route, { username: user, password: password}) 
        end
      
        def simulate_logout(logout_route = nil)
          logout_route ||= logout_url
          page.driver.get(logout_route)
        end
    end
  end
end