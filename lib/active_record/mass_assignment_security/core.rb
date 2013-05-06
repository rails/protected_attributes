module ActiveRecord
  module MassAssignmentSecurity
    module Core
      def initialize(attributes = nil, options = {})
        defaults = self.class.column_defaults.dup
        defaults.each { |k, v| defaults[k] = v.dup if v.duplicable? }

        @attributes   = self.class.initialize_attributes(defaults)
        @columns_hash = self.class.column_types.dup

        init_internals
        init_changed_attributes
        ensure_proper_type
        populate_with_current_scope_attributes

        assign_attributes(attributes, options) if attributes

        yield self if block_given?
        run_callbacks :initialize unless _initialize_callbacks.empty?
      end

      def init_internals
        super
        @mass_assignment_options = nil
      end
    end
  end
end
