module Sorcery
  module Controller
    module Adapters
      module Sinatra
        def self.included(base)
          base.class_eval do
            class << self
              # prepend a filter
              def prepend_filter(type, path = nil, options = {}, &block)
                return filters[type].unshift block unless path
                path, options = //, path if path.respond_to?(:each_pair)
                block, *arguments = compile!(type, path, block, options)
                prepend_filter(type) do
                  process_route(*arguments) { instance_eval(&block) }
                end
              end
            end
          end
          base.send(:include, InstanceMethods)
          base.extend(ClassMethods)
        end
        
        module InstanceMethods
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
        
        module ClassMethods
          def prepend_before_filter(filter)
            puts "called!"
            prepend_filter(:before) do
              send(filter)
            end
          end
        end
      end
    end
  end
end