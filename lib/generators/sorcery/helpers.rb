module Sorcery
  module Generators
    module Helpers
      private

      def sorcery_config_path
        "config/initializers/sorcery.rb"
      end

      # Either return the model passed in a classified form or return the default "User".
      def model_class_name
        options[:model] ? options[:model].classify : "User"
      end

      def model_path
        @model_path ||= File.join("app", "models", "#{file_path}.rb")
      end

      def file_path
        model_name.underscore
      end

      def namespace
        Rails::Generators.namespace if Rails::Generators.respond_to?(:namespace)
      end

      def namespaced?
        !!namespace
      end

      def model_name
        if namespaced?
          [namespace.to_s] + [model_class_name]
        else
          [model_class_name]
        end.join("::")
      end
    end
  end
end
