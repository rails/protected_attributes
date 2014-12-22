module ActiveRecord
  module Reflection
    if defined?(AbstractReflection)
      class AbstractReflection
        def build_association(*options, &block)
          klass.new(*options, &block)
        end
      end
    else
      class AssociationReflection
        def build_association(*options, &block)
          klass.new(*options, &block)
        end
      end
    end
  end
end
