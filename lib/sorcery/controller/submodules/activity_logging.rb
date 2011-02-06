module Sorcery
  module Controller
    module Submodules
      module ActivityLogging
        def self.included(base)
          base.send(:include, InstanceMethods)
          Config.after_login << :register_login_time_to_db
          Config.before_logout << :register_logout_time_to_db
        end
        
        module InstanceMethods
          def logged_in_users
            Config.user_class.logged_in_users
          end
          
          def register_login_time_to_db(user, credentials)
            user.last_login = Time.now.to_s(:db)
            user.save!(:validate => false)
          end
          
          def register_logout_time_to_db(user)
            user.last_logout = Time.now.to_s(:db)
            user.save!(:validate => false)
          end
        end
      end
    end
  end
end