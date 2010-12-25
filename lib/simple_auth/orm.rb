module SimpleAuth
  module ORM
    extend ActiveSupport::Concern
    
    module ClassMethods
      def activate_simple_auth!
        puts "hurray!"
      end
    end
  end
end