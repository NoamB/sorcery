module Sorcery
  module TestHelpers
    module Rails
      module Integration
        
        #Accepts arguments for user to login, route to use and HTTP method
        #Defaults - @user, 'sessions_url' and POST
        def login_user(user = nil, route = nil, http_method = :post)
          user ||= @user
          route ||= sessions_url

          username_attr = user.sorcery_config.username_attribute_names.first
          username = user.send(username_attr)
          page.driver.send(http_method, route, { :"#{username_attr}" => username, :password => 'secret' })
        end

        #Accepts route and HTTP method arguments
        #Default - 'logout_url' and GET
        def logout_user(route = nil, http_method = :get)
          route ||= logout_url
          page.driver.send(http_method, route)
        end
      end
    end
  end
end
