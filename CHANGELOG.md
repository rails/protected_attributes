## 1.0.2 (June 25, 2013)

* Sync #initialize override to latest rails implementation

  Fixes #14

* Fix "uninitialized constant ActiveRecord::MassAssignmentSecurity::NestedAttributes::ClassMethods::REJECT_ALL_BLANK_PROC"
  error when using `:all_blank` option.

  Fixes #8


## 1.0.1 (April 6, 2013)

* Fix "uninitialized constant `ActiveRecord::SchemaMigration`" error
  when checking pending migrations.

  Fixes rails/rails#10109


## 1.0.0 (January 22, 2013)

* First public version
