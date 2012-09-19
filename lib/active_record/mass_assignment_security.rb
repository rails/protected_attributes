require "active_record"
require "active_record/mass_assignment_security/associations"
require "active_record/mass_assignment_security/attribute_assignment"
require "active_record/mass_assignment_security/core"
require "active_record/mass_assignment_security/nested_attributes"
require "active_record/mass_assignment_security/persistence"
require "active_record/mass_assignment_security/reflection"
require "active_record/mass_assignment_security/relation"
require "active_record/mass_assignment_security/validations"
require "active_record/mass_assignment_security/associations"

class ActiveRecord::Base
  include ActiveRecord::MassAssignmentSecurity::Core
  include ActiveRecord::MassAssignmentSecurity::AttributeAssignment
  include ActiveRecord::MassAssignmentSecurity::Persistence
  include ActiveRecord::MassAssignmentSecurity::Relation
  include ActiveRecord::MassAssignmentSecurity::Validations
  include ActiveRecord::MassAssignmentSecurity::NestedAttributes
end

class ActiveRecord::Reflection::AssociationReflection
  include ActiveRecord::MassAssignmentSecurity::Reflection::AssociationReflection
end

module ActiveRecord::Associations
  class Association
    include ActiveRecord::MassAssignmentSecurity::Associations::Association
  end

  class CollectionAssociation
    include ActiveRecord::MassAssignmentSecurity::Associations::CollectionAssociation
  end

  class CollectionProxy
    include ActiveRecord::MassAssignmentSecurity::Associations::CollectionProxy
  end

  class HasManyThroughAssociation
    include ActiveRecord::MassAssignmentSecurity::Associations::HasManyThroughAssociation
  end

  class SingularAssociation
    include ActiveRecord::MassAssignmentSecurity::Associations::SingularAssociation
  end
end

ActiveRecord::SchemaMigration.attr_accessible(:version)
