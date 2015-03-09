## 1.0.9

* Fixes ThroughAssociation#build_record method on rails 4.1.10+

  Fixes #60, #63

* Fixes build_association method on rails 4.2.0+

  Fixes https://github.com/rails/rails/issues/18121

## 1.0.8 (June 16, 2014)

* Support Rails 4.0.6+ and 4.1.2+.

  Fixes #35


## 1.0.7 (March 12, 2014)

* Fix STI support on Active Record <= 4.0.3.


## 1.0.6 (March 10, 2014)

* Support to Rails 4.1

* Fix `CollectionProxy#new` method.

  Fixes #21


## 1.0.5 (November 1, 2013)

* Fix install error with Rails 4.0.1.
  Related with https://github.com/bundler/bundler/issues/2583


## 1.0.4 (October 18, 2013)

* Avoid override the entire Active Record initialization.

  Fixes rails/rails#12243


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
