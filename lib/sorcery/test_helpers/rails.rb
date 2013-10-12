module Sorcery
  module TestHelpers
    module Rails
      # logins a user and calls all callbacks
      def login_user(user = nil)
        user ||= @user
        @controller.send(:auto_login, user)
        @controller.send(:after_login!, user, [user.send(user.sorcery_config.username_attribute_names.first), 'secret'])
      end

      def logout_user
        @controller.send(:logout)
      end
    end
  end
end