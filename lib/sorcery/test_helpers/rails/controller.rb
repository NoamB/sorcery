module Sorcery
  module TestHelpers
    module Rails
      module Controller
        def login_user(user = nil, test_context = {})
          user ||= @user
          @controller.send(:auto_login, user)
          @controller.send(:after_login!, user, [user.send(user.sorcery_config.username_attribute_names.first), 'secret'])
        end

        def logout_user
          @controller.send(:logout)
        end

        def logged_in?
          @controller.send(:logged_in?)
        end
      end
    end
  end
end
