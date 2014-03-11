module ActiveRecord
  module MassAssignmentSecurity
    module Inheritance
      extend ActiveSupport::Concern

      module ClassMethods
      private
        # Detect the subclass from the inheritance column of attrs. If the inheritance column value
        # is not self or a valid subclass, raises ActiveRecord::SubclassNotFound
        # If this is a StrongParameters hash, and access to inheritance_column is not permitted,
        # this will ignore the inheritance column and return nil
        def subclass_from_attributes?(attrs)
          active_authorizer[:default].deny?(inheritance_column) ? nil : super
        end

        # Support Active Record <= 4.0.3, which uses the old method signature.
        def subclass_from_attrs(attrs)
          active_authorizer[:default].deny?(inheritance_column) ? nil : super
        end
      end
    end
  end
end
