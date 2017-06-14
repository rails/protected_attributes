require 'test_helper'
require 'ar_helper'
require 'active_record/mass_assignment_security'
require 'models/battle'
require 'models/company'
require 'models/group'
require 'models/keyboard'
require 'models/membership'
require 'models/person'
require 'models/pirate'
require 'models/subscriber'
require 'models/task'
require 'models/team'
require 'models/vampire'
require 'models/wolf'

module MassAssignmentTestHelpers
  def teardown
    super
    ActiveRecord::Base.send(:descendants).each do |klass|
      begin
        klass.delete_all
      rescue
      end
    end
  end

  def attributes_hash
    {
      :id => 5,
      :first_name => 'Josh',
      :gender   => 'm',
      :comments => 'rides a sweet bike'
    }
  end

  def assert_default_attributes(person, create = false)
    unless create
      assert_nil person.id
    else
      assert !!person.id
    end
    assert_equal 'Josh', person.first_name
    assert_equal 'm',    person.gender
    assert_nil person.comments
  end

  def assert_admin_attributes(person, create = false)
    unless create
      assert_nil person.id
    else
      assert !!person.id
    end
    assert_equal 'Josh', person.first_name
    assert_equal 'm',    person.gender
    assert_equal 'rides a sweet bike', person.comments
  end

  def assert_all_attributes(person)
    assert_equal 5, person.id
    assert_equal 'Josh', person.first_name
    assert_equal 'm',    person.gender
    assert_equal 'rides a sweet bike', person.comments
  end

  def with_strict_sanitizer
    ActiveRecord::Base.mass_assignment_sanitizer = :strict
    yield
  ensure
    ActiveRecord::Base.mass_assignment_sanitizer = :logger
  end
end

module MassAssignmentRelationTestHelpers
  def setup
    super
    @person = LoosePerson.create(attributes_hash)
  end
end

class AttributeSanitizationTest < ActiveSupport::TestCase
  include MassAssignmentTestHelpers

  def test_customized_primary_key_remains_protected
    subscriber = Subscriber.new(:nick => 'webster123', :name => 'nice try')
    assert_nil subscriber.id

    keyboard = Keyboard.new(:key_number => 9, :name => 'nice try')
    assert_nil keyboard.id
  end

  def test_customized_primary_key_remains_protected_when_referred_to_as_id
    subscriber = Subscriber.new(:id => 'webster123', :name => 'nice try')
    assert_nil subscriber.id

    keyboard = Keyboard.new(:id => 9, :name => 'nice try')
    assert_nil keyboard.id
  end

  def test_mass_assigning_invalid_attribute
    firm = Firm.new

    assert_raise(ActiveRecord::UnknownAttributeError) do
      firm.attributes = { "id" => 5, "type" => "Client", "i_dont_even_exist" => 20 }
    end
  end

  def test_mass_assigning_does_not_choke_on_nil
    assert_nil Firm.new.assign_attributes(nil)
  end

  def test_mass_assigning_does_not_choke_on_empty_hash
    assert_nil Firm.new.assign_attributes({})
  end

  def test_assign_attributes_uses_default_role_when_no_role_is_provided
    p = LoosePerson.new
    p.assign_attributes(attributes_hash)

    assert_default_attributes(p)
  end

  def test_assign_attributes_skips_mass_assignment_security_protection_when_without_protection_is_used
    p = LoosePerson.new
    p.assign_attributes(attributes_hash, :without_protection => true)

    assert_all_attributes(p)
  end

  def test_assign_attributes_with_default_role_and_attr_protected_attributes
    p = LoosePerson.new
    p.assign_attributes(attributes_hash, :as => :default)

    assert_default_attributes(p)
  end

  def test_assign_attributes_with_admin_role_and_attr_protected_attributes
    p = LoosePerson.new
    p.assign_attributes(attributes_hash, :as => :admin)

    assert_admin_attributes(p)
  end

  def test_assign_attributes_with_default_role_and_attr_accessible_attributes
    p = TightPerson.new
    p.assign_attributes(attributes_hash, :as => :default)

    assert_default_attributes(p)
  end

  def test_assign_attributes_with_admin_role_and_attr_accessible_attributes
    p = TightPerson.new
    p.assign_attributes(attributes_hash, :as => :admin)

    assert_admin_attributes(p)
  end

  def test_new_with_attr_accessible_attributes
    p = TightPerson.new(attributes_hash)

    assert_default_attributes(p)
  end

  def test_new_with_attr_protected_attributes
    p = LoosePerson.new(attributes_hash)

    assert_default_attributes(p)
  end

  def test_create_with_attr_accessible_attributes
    p = TightPerson.create(attributes_hash)

    assert_default_attributes(p, true)
  end

  def test_create_with_attr_protected_attributes
    p = LoosePerson.create(attributes_hash)

    assert_default_attributes(p, true)
  end

  def test_new_with_admin_role_with_attr_accessible_attributes
    p = TightPerson.new(attributes_hash, :as => :admin)

    assert_admin_attributes(p)
  end

  def test_new_with_admin_role_with_attr_protected_attributes
    p = LoosePerson.new(attributes_hash, :as => :admin)

    assert_admin_attributes(p)
  end

  def test_create_with_admin_role_with_attr_accessible_attributes
    p = TightPerson.create(attributes_hash, :as => :admin)

    assert_admin_attributes(p, true)
  end

  def test_create_with_admin_role_with_attr_protected_attributes
    p = LoosePerson.create(attributes_hash, :as => :admin)

    assert_admin_attributes(p, true)
  end

  def test_create_with_bang_with_admin_role_with_attr_accessible_attributes
    p = TightPerson.create!(attributes_hash, :as => :admin)

    assert_admin_attributes(p, true)
  end

  def test_create_with_bang_with_admin_role_with_attr_protected_attributes
    p = LoosePerson.create!(attributes_hash, :as => :admin)

    assert_admin_attributes(p, true)
  end

  def test_new_with_without_protection_with_attr_accessible_attributes
    p = TightPerson.new(attributes_hash, :without_protection => true)

    assert_all_attributes(p)
  end

  def test_new_with_without_protection_with_attr_protected_attributes
    p = LoosePerson.new(attributes_hash, :without_protection => true)

    assert_all_attributes(p)
  end

  def test_create_with_without_protection_with_attr_accessible_attributes
    p = TightPerson.create(attributes_hash, :without_protection => true)

    assert_all_attributes(p)
  end

  def test_create_with_without_protection_with_attr_protected_attributes
    p = LoosePerson.create(attributes_hash, :without_protection => true)

    assert_all_attributes(p)
  end

  def test_create_with_bang_with_without_protection_with_attr_accessible_attributes
    p = TightPerson.create!(attributes_hash, :without_protection => true)

    assert_all_attributes(p)
  end

  def test_create_with_bang_with_without_protection_with_attr_protected_attributes
    p = LoosePerson.create!(attributes_hash, :without_protection => true)

    assert_all_attributes(p)
  end

  def test_protection_against_class_attribute_writers
    attribute_writers = [:logger, :configurations, :primary_key_prefix_type, :table_name_prefix, :table_name_suffix, :pluralize_table_names,
     :default_timezone, :schema_format, :lock_optimistically, :timestamped_migrations, :default_scopes,
     :connection_handler, :nested_attributes_options,
     :attribute_method_matchers, :time_zone_aware_attributes, :skip_time_zone_conversion_for_attributes]

    attribute_writers.push(:_attr_readonly) if ActiveRecord::VERSION::MAJOR == 4 && ActiveRecord::VERSION::MINOR == 0

    attribute_writers.each do |method|
      assert_respond_to Task, method
      assert_respond_to Task, "#{method}="
      assert_respond_to Task.new, method unless method == :configurations && !(ActiveRecord::VERSION::MAJOR == 4 && ActiveRecord::VERSION::MINOR == 0)
      assert !Task.new.respond_to?("#{method}=")
    end
  end

  def test_new_with_protected_inheritance_column
    firm = Company.new(type: "Firm")
    assert_equal Company, firm.class
  end

  def test_new_with_accessible_inheritance_column
    corporation = Corporation.new(type: "SpecialCorporation")
    assert_equal SpecialCorporation, corporation.class
  end

  def test_new_with_invalid_inheritance_column_class
    assert_raise(ActiveRecord::SubclassNotFound) { Corporation.new(type: "InvalidCorporation") }
  end

  def test_new_with_unrelated_inheritance_column_class
    assert_raise(ActiveRecord::SubclassNotFound) { Corporation.new(type: "Person") }
  end

  def test_update_attributes_as_admin
    person = TightPerson.create({ "first_name" => 'Joshua' })
    person.update_attributes({ "first_name" => 'Josh', "gender" => 'm', "comments" => 'from NZ' }, :as => :admin)
    person.reload

    assert_equal 'Josh',    person.first_name
    assert_equal 'm',       person.gender
    assert_equal 'from NZ', person.comments
  end

  def test_update_attributes_without_protection
    person = TightPerson.create({ "first_name" => 'Joshua' })
    person.update_attributes({ "first_name" => 'Josh', "gender" => 'm', "comments" => 'from NZ' }, :without_protection => true)
    person.reload

    assert_equal 'Josh',    person.first_name
    assert_equal 'm',       person.gender
    assert_equal 'from NZ', person.comments
  end

  def test_update_attributes_with_bang_as_admin
    person = TightPerson.create({ "first_name" => 'Joshua' })
    person.update_attributes!({ "first_name" => 'Josh', "gender" => 'm', "comments" => 'from NZ' }, :as => :admin)
    person.reload

    assert_equal 'Josh', person.first_name
    assert_equal 'm',    person.gender
    assert_equal 'from NZ', person.comments
  end

  def test_update_attributes_with_bang_without_protection
    person = TightPerson.create({ "first_name" => 'Joshua' })
    person.update_attributes!({ "first_name" => 'Josh', "gender" => 'm', "comments" => 'from NZ' }, :without_protection => true)
    person.reload

    assert_equal 'Josh', person.first_name
    assert_equal 'm',    person.gender
    assert_equal 'from NZ', person.comments
  end

  def test_update_as_admin
    person = TightPerson.create({ "first_name" => 'Joshua' })
    person.update({ "first_name" => 'Josh', "gender" => 'm', "comments" => 'from NZ' }, :as => :admin)
    person.reload

    assert_equal 'Josh',    person.first_name
    assert_equal 'm',       person.gender
    assert_equal 'from NZ', person.comments
  end

  def test_update_without_protection
    person = TightPerson.create({ "first_name" => 'Joshua' })
    person.update({ "first_name" => 'Josh', "gender" => 'm', "comments" => 'from NZ' }, :without_protection => true)
    person.reload

    assert_equal 'Josh',    person.first_name
    assert_equal 'm',       person.gender
    assert_equal 'from NZ', person.comments
  end

  def test_update_with_bang_as_admin
    person = TightPerson.create({ "first_name" => 'Joshua' })
    person.update!({ "first_name" => 'Josh', "gender" => 'm', "comments" => 'from NZ' }, :as => :admin)
    person.reload

    assert_equal 'Josh', person.first_name
    assert_equal 'm',    person.gender
    assert_equal 'from NZ', person.comments
  end

  def test_update_with_bang_without_protection
    person = TightPerson.create({ "first_name" => 'Joshua' })
    person.update!({ "first_name" => 'Josh', "gender" => 'm', "comments" => 'from NZ' }, :without_protection => true)
    person.reload

    assert_equal 'Josh', person.first_name
    assert_equal 'm',    person.gender
    assert_equal 'from NZ', person.comments
  end
end

class MassAssignmentSecurityRelationTest < ActiveSupport::TestCase
  include MassAssignmentTestHelpers

  def test_find_or_initialize_by_with_attr_accessible_attributes
    p = TightPerson.where(first_name: 'Josh').first_or_initialize(attributes_hash)

    assert_default_attributes(p)
  end

  def test_find_or_initialize_by_with_admin_role_with_attr_accessible_attributes
    p = TightPerson.where(first_name: 'Josh').first_or_initialize(attributes_hash, as: :admin)

    assert_admin_attributes(p)
  end

  def test_find_or_initialize_by_with_attr_protected_attributes
    p = LoosePerson.where(first_name: 'Josh').first_or_initialize(attributes_hash)

    assert_default_attributes(p)
  end

  def test_find_or_initialize_by_with_admin_role_with_attr_protected_attributes
    p = LoosePerson.where(first_name: 'Josh').first_or_initialize(attributes_hash, as: :admin)

    assert_admin_attributes(p)
  end

  def test_find_or_create_by_with_attr_accessible_attributes
    p = TightPerson.where(first_name: 'Josh').first_or_create(attributes_hash)

    assert_default_attributes(p, true)
  end

  def test_find_or_create_by_with_admin_role_with_attr_accessible_attributes
    p = TightPerson.where(first_name: 'Josh').first_or_create(attributes_hash, as: :admin)

    assert_admin_attributes(p, true)
  end

  def test_find_or_create_by_with_attr_protected_attributes
    p = LoosePerson.where(first_name: 'Josh').first_or_create(attributes_hash)

    assert_default_attributes(p, true)
  end

  def test_find_or_create_by_with_admin_role_with_attr_protected_attributes
    p = LoosePerson.where(first_name: 'Josh').first_or_create(attributes_hash, as: :admin)

    assert_admin_attributes(p, true)
  end

  def test_find_or_create_by_bang_with_attr_accessible_attributes
    p = TightPerson.where(first_name: 'Josh').first_or_create!(attributes_hash)

    assert_default_attributes(p, true)
  end

  def test_find_or_create_by_bang_with_admin_role_with_attr_accessible_attributes
    p = TightPerson.where(first_name: 'Josh').first_or_create!(attributes_hash, as: :admin)

    assert_admin_attributes(p, true)
  end

  def test_find_or_create_by_bang_with_attr_protected_attributes
    p = LoosePerson.where(first_name: 'Josh').first_or_create!(attributes_hash)

    assert_default_attributes(p, true)
  end

  def test_find_or_create_by_bang_with_admin_role_with_attr_protected_attributes
    p = LoosePerson.where(first_name: 'Josh').first_or_create!(attributes_hash, as: :admin)

    assert_admin_attributes(p, true)
  end
end

class MassAssignmentSecurityFindersTest < ActiveSupport::TestCase
  include MassAssignmentTestHelpers

  def test_find_or_initialize_by_with_attr_accessible_attributes
    p = TightPerson.find_or_initialize_by(attributes_hash)

    assert_default_attributes(p)
  end

  def test_find_or_initialize_by_with_admin_role_with_attr_accessible_attributes
    p = TightPerson.find_or_initialize_by(attributes_hash, as: :admin)

    assert_admin_attributes(p)
  end

  def test_find_or_initialize_by_with_attr_protected_attributes
    p = LoosePerson.find_or_initialize_by(attributes_hash)

    assert_default_attributes(p)
  end

  def test_find_or_initialize_by_with_admin_role_with_attr_protected_attributes
    p = LoosePerson.find_or_initialize_by(attributes_hash, as: :admin)

    assert_admin_attributes(p)
  end

  def test_find_or_create_by_with_attr_accessible_attributes
    p = TightPerson.find_or_create_by(attributes_hash)

    assert_default_attributes(p, true)
  end

  def test_find_or_create_by_with_admin_role_with_attr_accessible_attributes
    p = TightPerson.find_or_create_by(attributes_hash, as: :admin)

    assert_admin_attributes(p, true)
  end

  def test_find_or_create_by_with_attr_protected_attributes
    p = LoosePerson.find_or_create_by(attributes_hash)

    assert_default_attributes(p, true)
  end

  def test_find_or_create_by_with_admin_role_with_attr_protected_attributes
    p = LoosePerson.find_or_create_by(attributes_hash, as: :admin)

    assert_admin_attributes(p, true)
  end

  def test_find_or_create_by_bang_with_attr_accessible_attributes
    p = TightPerson.find_or_create_by!(attributes_hash)

    assert_default_attributes(p, true)
  end

  def test_find_or_create_by_bang_with_admin_role_with_attr_accessible_attributes
    p = TightPerson.find_or_create_by!(attributes_hash, as: :admin)

    assert_admin_attributes(p, true)
  end

  def test_find_or_create_by_bang_with_attr_protected_attributes
    p = LoosePerson.find_or_create_by!(attributes_hash)

    assert_default_attributes(p, true)
  end

  def test_find_or_create_by_bang_with_admin_role_with_attr_protected_attributes
    p = LoosePerson.find_or_create_by!(attributes_hash, as: :admin)

    assert_admin_attributes(p, true)
  end
end

if ActiveRecord::VERSION::MAJOR == 4 && ActiveRecord::VERSION::MINOR == 0
  # This class should be deleted when we remove activerecord-deprecated_finders as a
  # dependency.
  class MassAssignmentSecurityDeprecatedFindersTest < ActiveSupport::TestCase
    include MassAssignmentTestHelpers

    def setup
      super
      @deprecation_behavior = ActiveSupport::Deprecation.behavior
      ActiveSupport::Deprecation.behavior = :silence
    end

    def teardown
      super
      ActiveSupport::Deprecation.behavior = @deprecation_behavior
    end

    def test_find_or_initialize_by_with_attr_accessible_attributes
      p = TightPerson.find_or_initialize_by_first_name('Josh', attributes_hash)

      assert_default_attributes(p)
    end

    def test_find_or_initialize_by_with_admin_role_with_attr_accessible_attributes
      p = TightPerson.find_or_initialize_by_first_name('Josh', attributes_hash, :as => :admin)

      assert_admin_attributes(p)
    end

    def test_find_or_initialize_by_with_attr_protected_attributes
      p = LoosePerson.find_or_initialize_by_first_name('Josh', attributes_hash)

      assert_default_attributes(p)
    end

    def test_find_or_initialize_by_with_admin_role_with_attr_protected_attributes
      p = LoosePerson.find_or_initialize_by_first_name('Josh', attributes_hash, :as => :admin)

      assert_admin_attributes(p)
    end

    def test_find_or_create_by_with_attr_accessible_attributes
      p = TightPerson.find_or_create_by_first_name('Josh', attributes_hash)

      assert_default_attributes(p, true)
    end

    def test_find_or_create_by_with_admin_role_with_attr_accessible_attributes
      p = TightPerson.find_or_create_by_first_name('Josh', attributes_hash, :as => :admin)

      assert_admin_attributes(p, true)
    end

    def test_find_or_create_by_with_attr_protected_attributes
      p = LoosePerson.find_or_create_by_first_name('Josh', attributes_hash)

      assert_default_attributes(p, true)
    end

    def test_find_or_create_by_with_admin_role_with_attr_protected_attributes
      p = LoosePerson.find_or_create_by_first_name('Josh', attributes_hash, :as => :admin)

      assert_admin_attributes(p, true)
    end
  end
end

class MassAssignmentSecurityHasOneRelationsTest < ActiveSupport::TestCase
  include MassAssignmentTestHelpers
  include MassAssignmentRelationTestHelpers

  # build

  def test_has_one_build_with_attr_protected_attributes
    best_friend = @person.build_best_friend(attributes_hash)
    assert_default_attributes(best_friend)
  end

  def test_has_one_build_with_attr_accessible_attributes
    best_friend = @person.build_best_friend(attributes_hash)
    assert_default_attributes(best_friend)
  end

  def test_has_one_build_with_admin_role_with_attr_protected_attributes
    best_friend = @person.build_best_friend(attributes_hash, :as => :admin)
    assert_admin_attributes(best_friend)
  end

  def test_has_one_build_with_admin_role_with_attr_accessible_attributes
    best_friend = @person.build_best_friend(attributes_hash, :as => :admin)
    assert_admin_attributes(best_friend)
  end

  def test_has_one_build_without_protection
    best_friend = @person.build_best_friend(attributes_hash, :without_protection => true)
    assert_all_attributes(best_friend)
  end

  def test_has_one_build_with_strict_sanitizer
    with_strict_sanitizer do
      best_friend = @person.build_best_friend(attributes_hash.except(:id, :comments))
      assert_equal @person.id, best_friend.best_friend_id
    end
  end

  # create

  def test_has_one_create_with_attr_protected_attributes
    best_friend = @person.create_best_friend(attributes_hash)
    assert_default_attributes(best_friend, true)
  end

  def test_has_one_create_with_attr_accessible_attributes
    best_friend = @person.create_best_friend(attributes_hash)
    assert_default_attributes(best_friend, true)
  end

  def test_has_one_create_with_admin_role_with_attr_protected_attributes
    best_friend = @person.create_best_friend(attributes_hash, :as => :admin)
    assert_admin_attributes(best_friend, true)
  end

  def test_has_one_create_with_admin_role_with_attr_accessible_attributes
    best_friend = @person.create_best_friend(attributes_hash, :as => :admin)
    assert_admin_attributes(best_friend, true)
  end

  def test_has_one_create_without_protection
    best_friend = @person.create_best_friend(attributes_hash, :without_protection => true)
    assert_all_attributes(best_friend)
  end

  def test_has_one_create_with_strict_sanitizer
    with_strict_sanitizer do
      best_friend = @person.create_best_friend(attributes_hash.except(:id, :comments))
      assert_equal @person.id, best_friend.best_friend_id
    end
  end

  # create!

  def test_has_one_create_with_bang_with_attr_protected_attributes
    best_friend = @person.create_best_friend!(attributes_hash)
    assert_default_attributes(best_friend, true)
  end

  def test_has_one_create_with_bang_with_attr_accessible_attributes
    best_friend = @person.create_best_friend!(attributes_hash)
    assert_default_attributes(best_friend, true)
  end

  def test_has_one_create_with_bang_with_admin_role_with_attr_protected_attributes
    best_friend = @person.create_best_friend!(attributes_hash, :as => :admin)
    assert_admin_attributes(best_friend, true)
  end

  def test_has_one_create_with_bang_with_admin_role_with_attr_accessible_attributes
    best_friend = @person.create_best_friend!(attributes_hash, :as => :admin)
    assert_admin_attributes(best_friend, true)
  end

  def test_has_one_create_with_bang_without_protection
    best_friend = @person.create_best_friend!(attributes_hash, :without_protection => true)
    assert_all_attributes(best_friend)
  end

  def test_has_one_create_with_bang_with_strict_sanitizer
    with_strict_sanitizer do
      best_friend = @person.create_best_friend!(attributes_hash.except(:id, :comments))
      assert_equal @person.id, best_friend.best_friend_id
    end
  end

end


class MassAssignmentSecurityBelongsToRelationsTest < ActiveSupport::TestCase
  include MassAssignmentTestHelpers
  include MassAssignmentRelationTestHelpers

  # build

  def test_belongs_to_build_with_attr_protected_attributes
    best_friend = @person.build_best_friend_of(attributes_hash)
    assert_default_attributes(best_friend)
  end

  def test_belongs_to_build_with_attr_accessible_attributes
    best_friend = @person.build_best_friend_of(attributes_hash)
    assert_default_attributes(best_friend)
  end

  def test_belongs_to_build_with_admin_role_with_attr_protected_attributes
    best_friend = @person.build_best_friend_of(attributes_hash, :as => :admin)
    assert_admin_attributes(best_friend)
  end

  def test_belongs_to_build_with_admin_role_with_attr_accessible_attributes
    best_friend = @person.build_best_friend_of(attributes_hash, :as => :admin)
    assert_admin_attributes(best_friend)
  end

  def test_belongs_to_build_without_protection
    best_friend = @person.build_best_friend_of(attributes_hash, :without_protection => true)
    assert_all_attributes(best_friend)
  end

  # create

  def test_belongs_to_create_with_attr_protected_attributes
    best_friend = @person.create_best_friend_of(attributes_hash)
    assert_default_attributes(best_friend, true)
  end

  def test_belongs_to_create_with_attr_accessible_attributes
    best_friend = @person.create_best_friend_of(attributes_hash)
    assert_default_attributes(best_friend, true)
  end

  def test_belongs_to_create_with_admin_role_with_attr_protected_attributes
    best_friend = @person.create_best_friend_of(attributes_hash, :as => :admin)
    assert_admin_attributes(best_friend, true)
  end

  def test_belongs_to_create_with_admin_role_with_attr_accessible_attributes
    best_friend = @person.create_best_friend_of(attributes_hash, :as => :admin)
    assert_admin_attributes(best_friend, true)
  end

  def test_belongs_to_create_without_protection
    best_friend = @person.create_best_friend_of(attributes_hash, :without_protection => true)
    assert_all_attributes(best_friend)
  end

  def test_belongs_to_create_with_strict_sanitizer
    with_strict_sanitizer do
      best_friend = @person.create_best_friend_of(attributes_hash.except(:id, :comments))
      assert_equal best_friend.id, @person.best_friend_of_id
    end
  end

  # create!

  def test_belongs_to_create_with_bang_with_attr_protected_attributes
    best_friend = @person.create_best_friend!(attributes_hash)
    assert_default_attributes(best_friend, true)
  end

  def test_belongs_to_create_with_bang_with_attr_accessible_attributes
    best_friend = @person.create_best_friend!(attributes_hash)
    assert_default_attributes(best_friend, true)
  end

  def test_belongs_to_create_with_bang_with_admin_role_with_attr_protected_attributes
    best_friend = @person.create_best_friend!(attributes_hash, :as => :admin)
    assert_admin_attributes(best_friend, true)
  end

  def test_belongs_to_create_with_bang_with_admin_role_with_attr_accessible_attributes
    best_friend = @person.create_best_friend!(attributes_hash, :as => :admin)
    assert_admin_attributes(best_friend, true)
  end

  def test_belongs_to_create_with_bang_without_protection
    best_friend = @person.create_best_friend!(attributes_hash, :without_protection => true)
    assert_all_attributes(best_friend)
  end

  def test_belongs_to_create_with_bang_with_strict_sanitizer
    with_strict_sanitizer do
      best_friend = @person.create_best_friend_of!(attributes_hash.except(:id, :comments))
      assert_equal best_friend.id, @person.best_friend_of_id
    end
  end

end


class MassAssignmentSecurityHasManyRelationsTest < ActiveSupport::TestCase
  include MassAssignmentTestHelpers
  include MassAssignmentRelationTestHelpers

  # build

  def test_has_many_build_with_attr_protected_attributes
    best_friend = @person.best_friends.build(attributes_hash)
    assert_default_attributes(best_friend)
  end

  def test_has_many_build_with_attr_accessible_attributes
    best_friend = @person.best_friends.build(attributes_hash)
    assert_default_attributes(best_friend)
  end

  def test_has_many_build_with_admin_role_with_attr_protected_attributes
    best_friend = @person.best_friends.build(attributes_hash, :as => :admin)
    assert_admin_attributes(best_friend)
  end

  def test_has_many_build_with_admin_role_with_attr_accessible_attributes
    best_friend = @person.best_friends.build(attributes_hash, :as => :admin)
    assert_admin_attributes(best_friend)
  end

  def test_has_many_build_without_protection
    best_friend = @person.best_friends.build(attributes_hash, :without_protection => true)
    assert_all_attributes(best_friend)
  end

  def test_has_many_build_with_strict_sanitizer
    with_strict_sanitizer do
      best_friend = @person.best_friends.build(attributes_hash.except(:id, :comments))
      assert_equal @person.id, best_friend.best_friend_id
    end
  end

  def test_has_many_through_build_with_attr_accessible_attributes
    group = Group.create!
    pirate = group.members.build(name: "Murphy")
    assert_equal "Murphy", pirate.name
  end

  # new

  def test_has_many_new_with_attr_protected_attributes
    best_friend = @person.best_friends.new(attributes_hash)
    assert_default_attributes(best_friend)
  end

  def test_has_many_new_with_attr_accessible_attributes
    best_friend = @person.best_friends.new(attributes_hash)
    assert_default_attributes(best_friend)
  end

  def test_has_many_new_with_admin_role_with_attr_protected_attributes
    best_friend = @person.best_friends.new(attributes_hash, :as => :admin)
    assert_admin_attributes(best_friend)
  end

  def test_has_many_new_with_admin_role_with_attr_accessible_attributes
    best_friend = @person.best_friends.new(attributes_hash, :as => :admin)
    assert_admin_attributes(best_friend)
  end

  def test_has_many_new_without_protection
    best_friend = @person.best_friends.new(attributes_hash, :without_protection => true)
    assert_all_attributes(best_friend)
  end

  def test_has_many_new_with_strict_sanitizer
    with_strict_sanitizer do
      best_friend = @person.best_friends.new(attributes_hash.except(:id, :comments))
      assert_equal @person.id, best_friend.best_friend_id
    end
  end

  # create

  def test_has_many_create_with_attr_protected_attributes
    best_friend = @person.best_friends.create(attributes_hash)
    assert_default_attributes(best_friend, true)
  end

  def test_has_many_create_with_attr_accessible_attributes
    best_friend = @person.best_friends.create(attributes_hash)
    assert_default_attributes(best_friend, true)
  end

  def test_has_many_create_with_admin_role_with_attr_protected_attributes
    best_friend = @person.best_friends.create(attributes_hash, :as => :admin)
    assert_admin_attributes(best_friend, true)
  end

  def test_has_many_create_with_admin_role_with_attr_accessible_attributes
    best_friend = @person.best_friends.create(attributes_hash, :as => :admin)
    assert_admin_attributes(best_friend, true)
  end

  def test_has_many_create_without_protection
    best_friend = @person.best_friends.create(attributes_hash, :without_protection => true)
    assert_all_attributes(best_friend)
  end

  def test_has_many_create_with_strict_sanitizer
    with_strict_sanitizer do
      best_friend = @person.best_friends.create(attributes_hash.except(:id, :comments))
      assert_equal @person.id, best_friend.best_friend_id
    end
  end

  # create!

  def test_has_many_create_with_bang_with_attr_protected_attributes
    best_friend = @person.best_friends.create!(attributes_hash)
    assert_default_attributes(best_friend, true)
  end

  def test_has_many_create_with_bang_with_attr_accessible_attributes
    best_friend = @person.best_friends.create!(attributes_hash)
    assert_default_attributes(best_friend, true)
  end

  def test_has_many_create_with_bang_with_admin_role_with_attr_protected_attributes
    best_friend = @person.best_friends.create!(attributes_hash, :as => :admin)
    assert_admin_attributes(best_friend, true)
  end

  def test_has_many_create_with_bang_with_admin_role_with_attr_accessible_attributes
    best_friend = @person.best_friends.create!(attributes_hash, :as => :admin)
    assert_admin_attributes(best_friend, true)
  end

  def test_has_many_create_with_bang_without_protection
    best_friend = @person.best_friends.create!(attributes_hash, :without_protection => true)
    assert_all_attributes(best_friend)
  end

  def test_has_many_create_with_bang_with_strict_sanitizer
    with_strict_sanitizer do
      best_friend = @person.best_friends.create!(attributes_hash.except(:id, :comments))
      assert_equal @person.id, best_friend.best_friend_id
    end
  end

  # concat

  def test_concat_has_many_through_association_member
    group = Group.create!
    pirate = Pirate.create!
    group.members << pirate
    assert_equal pirate.memberships.first, group.memberships.first
  end

  def test_concat_has_many_through_polymorphic_association
    team = Team.create!
    vampire = Vampire.create!
    wolf = Wolf.create!

    team.vampire_battles << vampire
    wolf.teams << team
    assert_equal team.wolf_battles.first, wolf
  end
end


class MassAssignmentSecurityNestedAttributesTest < ActiveSupport::TestCase
  include MassAssignmentTestHelpers

  def nested_attributes_hash(association, collection = false, except = [:id])
    if collection
      { :first_name => 'David' }.merge(:"#{association}_attributes" => [attributes_hash.except(*except)])
    else
      { :first_name => 'David' }.merge(:"#{association}_attributes" => attributes_hash.except(*except))
    end
  end

  # build

  def test_has_one_new_with_attr_protected_attributes
    person = LoosePerson.new(nested_attributes_hash(:best_friend))
    assert_default_attributes(person.best_friend)
  end

  def test_has_one_new_with_attr_accessible_attributes
    person = TightPerson.new(nested_attributes_hash(:best_friend))
    assert_default_attributes(person.best_friend)
  end

  def test_has_one_new_with_admin_role_with_attr_protected_attributes
    person = LoosePerson.new(nested_attributes_hash(:best_friend), :as => :admin)
    assert_admin_attributes(person.best_friend)
  end

  def test_has_one_new_with_admin_role_with_attr_accessible_attributes
    person = TightPerson.new(nested_attributes_hash(:best_friend), :as => :admin)
    assert_admin_attributes(person.best_friend)
  end

  def test_has_one_new_without_protection
    person = LoosePerson.new(nested_attributes_hash(:best_friend, false, nil), :without_protection => true)
    assert_all_attributes(person.best_friend)
  end

  def test_belongs_to_new_with_attr_protected_attributes
    person = LoosePerson.new(nested_attributes_hash(:best_friend_of))
    assert_default_attributes(person.best_friend_of)
  end

  def test_belongs_to_new_with_attr_accessible_attributes
    person = TightPerson.new(nested_attributes_hash(:best_friend_of))
    assert_default_attributes(person.best_friend_of)
  end

  def test_belongs_to_new_with_admin_role_with_attr_protected_attributes
    person = LoosePerson.new(nested_attributes_hash(:best_friend_of), :as => :admin)
    assert_admin_attributes(person.best_friend_of)
  end

  def test_belongs_to_new_with_admin_role_with_attr_accessible_attributes
    person = TightPerson.new(nested_attributes_hash(:best_friend_of), :as => :admin)
    assert_admin_attributes(person.best_friend_of)
  end

  def test_belongs_to_new_without_protection
    person = LoosePerson.new(nested_attributes_hash(:best_friend_of, false, nil), :without_protection => true)
    assert_all_attributes(person.best_friend_of)
  end

  def test_has_many_new_with_attr_protected_attributes
    person = LoosePerson.new(nested_attributes_hash(:best_friends, true))
    assert_default_attributes(person.best_friends.first)
  end

  def test_has_many_new_with_attr_accessible_attributes
    person = TightPerson.new(nested_attributes_hash(:best_friends, true))
    assert_default_attributes(person.best_friends.first)
  end

  def test_has_many_new_with_admin_role_with_attr_protected_attributes
    person = LoosePerson.new(nested_attributes_hash(:best_friends, true), :as => :admin)
    assert_admin_attributes(person.best_friends.first)
  end

  def test_has_many_new_with_admin_role_with_attr_accessible_attributes
    person = TightPerson.new(nested_attributes_hash(:best_friends, true), :as => :admin)
    assert_admin_attributes(person.best_friends.first)
  end

  def test_has_many_new_without_protection
    person = LoosePerson.new(nested_attributes_hash(:best_friends, true, nil), :without_protection => true)
    assert_all_attributes(person.best_friends.first)
  end

  # create

  def test_has_one_create_with_attr_protected_attributes
    person = LoosePerson.create(nested_attributes_hash(:best_friend))
    assert_default_attributes(person.best_friend, true)
  end

  def test_has_one_create_with_attr_accessible_attributes
    person = TightPerson.create(nested_attributes_hash(:best_friend))
    assert_default_attributes(person.best_friend, true)
  end

  def test_has_one_create_with_admin_role_with_attr_protected_attributes
    person = LoosePerson.create(nested_attributes_hash(:best_friend), :as => :admin)
    assert_admin_attributes(person.best_friend, true)
  end

  def test_has_one_create_with_admin_role_with_attr_accessible_attributes
    person = TightPerson.create(nested_attributes_hash(:best_friend), :as => :admin)
    assert_admin_attributes(person.best_friend, true)
  end

  def test_has_one_create_without_protection
    person = LoosePerson.create(nested_attributes_hash(:best_friend, false, nil), :without_protection => true)
    assert_all_attributes(person.best_friend)
  end

  def test_belongs_to_create_with_attr_protected_attributes
    person = LoosePerson.create(nested_attributes_hash(:best_friend_of))
    assert_default_attributes(person.best_friend_of, true)
  end

  def test_belongs_to_create_with_attr_accessible_attributes
    person = TightPerson.create(nested_attributes_hash(:best_friend_of))
    assert_default_attributes(person.best_friend_of, true)
  end

  def test_belongs_to_create_with_admin_role_with_attr_protected_attributes
    person = LoosePerson.create(nested_attributes_hash(:best_friend_of), :as => :admin)
    assert_admin_attributes(person.best_friend_of, true)
  end

  def test_belongs_to_create_with_admin_role_with_attr_accessible_attributes
    person = TightPerson.create(nested_attributes_hash(:best_friend_of), :as => :admin)
    assert_admin_attributes(person.best_friend_of, true)
  end

  def test_belongs_to_create_without_protection
    person = LoosePerson.create(nested_attributes_hash(:best_friend_of, false, nil), :without_protection => true)
    assert_all_attributes(person.best_friend_of)
  end

  def test_has_many_create_with_attr_protected_attributes
    person = LoosePerson.create(nested_attributes_hash(:best_friends, true))
    assert_default_attributes(person.best_friends.first, true)
  end

  def test_has_many_create_with_attr_accessible_attributes
    person = TightPerson.create(nested_attributes_hash(:best_friends, true))
    assert_default_attributes(person.best_friends.first, true)
  end

  def test_has_many_create_with_admin_role_with_attr_protected_attributes
    person = LoosePerson.create(nested_attributes_hash(:best_friends, true), :as => :admin)
    assert_admin_attributes(person.best_friends.first, true)
  end

  def test_has_many_create_with_admin_role_with_attr_accessible_attributes
    person = TightPerson.create(nested_attributes_hash(:best_friends, true), :as => :admin)
    assert_admin_attributes(person.best_friends.first, true)
  end

  def test_has_many_create_without_protection
    person = LoosePerson.create(nested_attributes_hash(:best_friends, true, nil), :without_protection => true)
    assert_all_attributes(person.best_friends.first)
  end

  # create!

  def test_has_one_create_with_bang_with_attr_protected_attributes
    person = LoosePerson.create!(nested_attributes_hash(:best_friend))
    assert_default_attributes(person.best_friend, true)
  end

  def test_has_one_create_with_bang_with_attr_accessible_attributes
    person = TightPerson.create!(nested_attributes_hash(:best_friend))
    assert_default_attributes(person.best_friend, true)
  end

  def test_has_one_create_with_bang_with_admin_role_with_attr_protected_attributes
    person = LoosePerson.create!(nested_attributes_hash(:best_friend), :as => :admin)
    assert_admin_attributes(person.best_friend, true)
  end

  def test_has_one_create_with_bang_with_admin_role_with_attr_accessible_attributes
    person = TightPerson.create!(nested_attributes_hash(:best_friend), :as => :admin)
    assert_admin_attributes(person.best_friend, true)
  end

  def test_has_one_create_with_bang_without_protection
    person = LoosePerson.create!(nested_attributes_hash(:best_friend, false, nil), :without_protection => true)
    assert_all_attributes(person.best_friend)
  end

  def test_belongs_to_create_with_bang_with_attr_protected_attributes
    person = LoosePerson.create!(nested_attributes_hash(:best_friend_of))
    assert_default_attributes(person.best_friend_of, true)
  end

  def test_belongs_to_create_with_bang_with_attr_accessible_attributes
    person = TightPerson.create!(nested_attributes_hash(:best_friend_of))
    assert_default_attributes(person.best_friend_of, true)
  end

  def test_belongs_to_create_with_bang_with_admin_role_with_attr_protected_attributes
    person = LoosePerson.create!(nested_attributes_hash(:best_friend_of), :as => :admin)
    assert_admin_attributes(person.best_friend_of, true)
  end

  def test_belongs_to_create_with_bang_with_admin_role_with_attr_accessible_attributes
    person = TightPerson.create!(nested_attributes_hash(:best_friend_of), :as => :admin)
    assert_admin_attributes(person.best_friend_of, true)
  end

  def test_belongs_to_create_with_bang_without_protection
    person = LoosePerson.create!(nested_attributes_hash(:best_friend_of, false, nil), :without_protection => true)
    assert_all_attributes(person.best_friend_of)
  end

  def test_has_many_create_with_bang_with_attr_protected_attributes
    person = LoosePerson.create!(nested_attributes_hash(:best_friends, true))
    assert_default_attributes(person.best_friends.first, true)
  end

  def test_has_many_create_with_bang_with_attr_accessible_attributes
    person = TightPerson.create!(nested_attributes_hash(:best_friends, true))
    assert_default_attributes(person.best_friends.first, true)
  end

  def test_has_many_create_with_bang_with_admin_role_with_attr_protected_attributes
    person = LoosePerson.create!(nested_attributes_hash(:best_friends, true), :as => :admin)
    assert_admin_attributes(person.best_friends.first, true)
  end

  def test_has_many_create_with_bang_with_admin_role_with_attr_accessible_attributes
    person = TightPerson.create!(nested_attributes_hash(:best_friends, true), :as => :admin)
    assert_admin_attributes(person.best_friends.first, true)
  end

  def test_has_many_create_with_bang_without_protection
    person = LoosePerson.create!(nested_attributes_hash(:best_friends, true, nil), :without_protection => true)
    assert_all_attributes(person.best_friends.first)
  end

  def test_mass_assignment_options_are_reset_after_exception
    person = NestedPerson.create!({ :first_name => 'David', :gender => 'm' }, :as => :admin)
    person.create_best_friend!({ :first_name => 'Jeremy', :gender => 'm' }, :as => :admin)

    attributes = { :best_friend_attributes => { :comments => 'rides a sweet bike' } }
    assert_raises(RuntimeError) { person.assign_attributes(attributes, :as => :admin) }
    assert_equal 'm', person.best_friend.gender

    person.best_friend_attributes = { :gender => 'f' }
    assert_equal 'm', person.best_friend.gender
  end

  def test_mass_assignment_options_are_nested_correctly
    person = NestedPerson.create!({ :first_name => 'David', :gender => 'm' }, :as => :admin)
    person.create_best_friend!({ :first_name => 'Jeremy', :gender => 'm' }, :as => :admin)

    attributes = { :best_friend_first_name => 'Josh', :best_friend_attributes => { :gender => 'f' } }
    person.assign_attributes(attributes, :as => :admin)
    assert_equal 'Josh', person.best_friend.first_name
    assert_equal 'f', person.best_friend.gender
  end

  def test_accepts_nested_attributes_for_and_protected_attributes_on_both_sides
    team = Team.create

    team.update_attributes({ :nested_battles_attributes => {
      '0' => { :team_id => Team.create.id },
      '1' => { :team_id => Team.create.id } }
    })

    assert_equal 2, Team.find(team.id).nested_battles.count
  end

  def test_accepts_nested_attributes_for_raises_when_limit_is_reached
    team = Team.create
    team.nested_attributes_options[:nested_battles].merge!(limit: 2)

    assert_raises(ActiveRecord::NestedAttributes::TooManyRecords) do
      team.nested_battles_attributes = {
        '0' => { :team_id => Team.create.id },
        '1' => { :team_id => Team.create.id },
        '2' => { :team_id => Team.create.id }
      }
    end
  end
end
