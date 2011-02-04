module Sorcery
  module Controller
    module Submodules
      module HTTPBasicAuth
        def self.included(base)
          base.send(:include, InstanceMethods)
          Config.login_sources << :login_from_basic_auth
        end
        
        module InstanceMethods

          protected
          
          def login_from_basic_auth
            authenticate_with_http_basic do |username, password|
              Config.user_class.authenticate(username, password)
            end
          end
        end

      end
    end
  end
end