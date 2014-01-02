module Sorcery
  module TestHelpers
    module Rails
      module Integration
        
        #Accepts arguments for user to login and route to use 
        #Defaults - @user and 'sessions_url'
        def login_user(user = nil, route = nil)
          user ||= @user
          username = user.send(user.sorcery_config.username_attribute_names.first)
          route ||= sessions_url
          page.driver.post(route, { username: username, password: 'secret' })
        end

        #Accepts route argument
        #Default - 'logout_url'
        def logout_user(route = nil)
          route ||= logout_url
          page.driver.get(route)
        end
      end
    end
  end
end
