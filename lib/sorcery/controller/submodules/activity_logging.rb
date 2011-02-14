module Sorcery
  module Controller
    module Submodules
      module ActivityLogging
        def self.included(base)
          base.send(:include, InstanceMethods)
          Config.after_login << :register_login_time_to_db
          Config.before_logout << :register_logout_time_to_db
          base.after_filter :register_last_activity_time_to_db
        end
        
        module InstanceMethods
          def logged_in_users
            Config.user_class.logged_in_users
            # A possible patch here:
            # we'll add the logged_in_user to the users list if he's not in it (can happen when he was inactive for more than activity timeout):
            #
            #   users.unshift!(logged_in_user) if logged_in? && users.find {|u| u.id == logged_in_user.id}.nil?
            #
            # disadvantages: can hurt performance.
          end
          
          protected
          
          def register_login_time_to_db(user, credentials)
            user.send(:"#{user.sorcery_config.last_login_at_attribute_name}=", Time.now.utc.to_s(:db))
            user.save!(:validate => false)
          end
          
          def register_logout_time_to_db(user)
            user.send(:"#{user.sorcery_config.last_logout_at_attribute_name}=", Time.now.utc.to_s(:db))
            user.save!(:validate => false)
          end
          
          # we do not update activity on logout
          def register_last_activity_time_to_db
            return if !logged_in?
            logged_in_user.send(:"#{logged_in_user.sorcery_config.last_activity_at_attribute_name}=", Time.now.utc.to_s(:db))
            logged_in_user.save!(:validate => false)
          end
        end
      end
    end
  end
end