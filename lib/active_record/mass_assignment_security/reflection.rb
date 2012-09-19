module ActiveRecord
  module MassAssignmentSecurity
    module Reflection
      module AssociationReflection
        def build_association(*options, &block)
          klass.new(*options, &block)
        end
      end
    end
  end
end
