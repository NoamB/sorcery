module Sorcery
  module Controller
    module Config
      class << self
        attr_accessor :submodules,
                      :user_class,                    # what class to use as the user class.
                      :not_authenticated_action,      # what controller action to call for non-authenticated users.

                      :save_return_to_url,            # when a non logged in user tries to enter a page that requires
                                                      # login, save the URL he wanted to reach,
                                                      # and send him there after login.

                      :cookie_domain,                 # set domain option for cookies

                      :login_sources,
                      :after_login,
                      :after_failed_login,
                      :before_logout,
                      :after_logout

        def init!
          @defaults = {
            :@user_class                           => nil,
            :@submodules                           => [],
            :@not_authenticated_action             => :not_authenticated,
            :@login_sources                        => [],
            :@after_login                          => [],
            :@after_failed_login                   => [],
            :@before_logout                        => [],
            :@after_logout                         => [],
            :@save_return_to_url                   => true,
            :@cookie_domain                        => nil
          }
        end

        # Resets all configuration options to their default values.
        def reset!
          @defaults.each do |k,v|
            instance_variable_set(k,v)
          end
        end

        def update!
          @defaults.each do |k,v|
            instance_variable_set(k,v) if !instance_variable_defined?(k)
          end
        end

        def user_config(&blk)
          block_given? ? @user_config = blk : @user_config
        end

        def configure(&blk)
          @configure_blk = blk
        end

        def configure!
          @configure_blk.call(self) if @configure_blk
        end
      end
      init!
      reset!
    end
  end
end
