module ActiveRecord
  module MassAssignmentSecurity
    module Core

      private

      def init_attributes(attributes, options)
        assign_attributes(attributes, options)
      end

      def init_internals
        super
        @mass_assignment_options = nil
      end
    end
  end
end
