## 1.0.3 (June 29, 2013)

* Fix "uninitialized constant ActiveRecord::MassAssignmentSecurity::NestedAttributes::ClassMethods::REJECT_ALL_BLANK_PROC"
  error when using `:all_blank` option.

  Fixes #8

* Fix `NoMethodError` exception when calling `raise_nested_attributes_record_not_found`.


## 1.0.2 (June 25, 2013)

* Sync #initialize override to latest rails implementation

  Fixes #14


## 1.0.1 (April 6, 2013)

* Fix "uninitialized constant `ActiveRecord::SchemaMigration`" error
  when checking pending migrations.

  Fixes rails/rails#10109


## 1.0.0 (January 22, 2013)

* First public version
