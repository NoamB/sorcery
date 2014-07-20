module Sorcery
  module Adapters
    class BaseAdapter
      def initialize(model)
        @model = model
      end

      def self.from(klass)
        @klass = klass
        self
      end

      def self.delete_all
        @klass.delete_all
      end

      def self.find(id)
        find_by_id(id)
      end
    end
  end
end
