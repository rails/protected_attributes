module ActiveRecord
  module Reflection
    class AbstractReflection
      def build_association(*options, &block)
        klass.new(*options, &block)
      end
    end
  end
end
