module Sorcery
  module Controller
    module Adapters
      module Sinatra
        def reset_session
          session.clear
        end
        
        def redirect_to(*args)
          args.pop if args.last.is_a?(Hash)
          redirect(*args)
        end
        
        def root_path
          '/'
        end
      end
    end
  end
end