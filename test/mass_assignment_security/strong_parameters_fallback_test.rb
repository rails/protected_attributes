require 'test_helper'
require 'ar_helper'
require 'rack/test'
require 'action_controller/metal/strong_parameters'
require 'active_record/mass_assignment_security'
require 'active_model/mass_assignment_security'
require 'models/book'
require 'models/person'


class StrongParametersFallbackTest < ActiveModel::TestCase
  test "AR, use strong parameters when no protection macro (attr_accessible, attr_protected) was used." do
    untrusted_params = ActionController::Parameters.new(title: 'Agile Development with Ruby on Rails')

    assert_raises(ActiveModel::ForbiddenAttributesError) { Book.new untrusted_params }
    assert_raises(ActiveModel::ForbiddenAttributesError) { Book.new.attributes = untrusted_params }
    assert_raises(ActiveModel::ForbiddenAttributesError) { Book.where(title: 'Agile Development with Ruby on Rails').first_or_initialize(untrusted_params) }
    assert_raises(ActiveModel::ForbiddenAttributesError) { Book.where(title: 'Agile Development with Ruby on Rails').first_or_create(untrusted_params) }
    assert_raises(ActiveModel::ForbiddenAttributesError) { Book.where(title: 'Agile Development with Ruby on Rails').first_or_create!(untrusted_params) }
    assert_raises(ActiveModel::ForbiddenAttributesError) { Book.find_or_initialize_by(untrusted_params) }
    assert_raises(ActiveModel::ForbiddenAttributesError) { Book.find_or_create_by(untrusted_params) }
    assert_raises(ActiveModel::ForbiddenAttributesError) { Book.find_or_create_by!(untrusted_params) }
  end

  test "AR, ignore strong parameters when protection macro was used" do
    untrusted_params = ActionController::Parameters.new(first_name: "John")

    assert_nothing_raised { TightPerson.new untrusted_params }
    assert_nothing_raised { TightPerson.new.attributes = untrusted_params }
    assert_nothing_raised { TightPerson.where(first_name: "John").first_or_initialize(untrusted_params) }
    assert_nothing_raised { TightPerson.where(first_name: "John").first_or_create(untrusted_params) }
    assert_nothing_raised { TightPerson.where(first_name: "John").first_or_create!(untrusted_params) }
    assert_nothing_raised { TightPerson.find_or_initialize_by(untrusted_params) }
    assert_nothing_raised { TightPerson.find_or_create_by(untrusted_params) }
    assert_nothing_raised { TightPerson.find_or_create_by!(untrusted_params) }
  end

  test "with PORO including MassAssignmentSecurity that uses a protection marco" do
    klass = Class.new do
      include ActiveModel::MassAssignmentSecurity
      attr_protected :admin
    end

    untrusted_params = ActionController::Parameters.new(admin: true)
    assert_equal({}, klass.new.send(:sanitize_for_mass_assignment, untrusted_params))
  end

  test "with PORO including MassAssignmentSecurity that does not use a protection marco" do
    klass = Class.new do
      include ActiveModel::MassAssignmentSecurity
    end

    untrusted_params = ActionController::Parameters.new(name: "37 signals")
    assert_raises ActiveModel::ForbiddenAttributesError do
      klass.new.send :sanitize_for_mass_assignment, untrusted_params
    end
  end
end
