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
require "active_record/mass_assignment_security/inheritance"

class ActiveRecord::Base
  include ActiveRecord::MassAssignmentSecurity::Core
  include ActiveRecord::MassAssignmentSecurity::AttributeAssignment
  include ActiveRecord::MassAssignmentSecurity::Persistence
  include ActiveRecord::MassAssignmentSecurity::Relation
  include ActiveRecord::MassAssignmentSecurity::Validations
  include ActiveRecord::MassAssignmentSecurity::NestedAttributes
  include ActiveRecord::MassAssignmentSecurity::Inheritance
end

class ActiveRecord::SchemaMigration < ActiveRecord::Base
  attr_accessible :version
end
