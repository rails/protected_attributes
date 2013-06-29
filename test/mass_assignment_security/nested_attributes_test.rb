require 'test_helper'

class NestedAttributesTest < ActiveModel::TestCase
  test "REJECT_ALL_BLANK_PROC is a proc" do
    assert_kind_of Proc, ActiveRecord::MassAssignmentSecurity::NestedAttributes::ClassMethods::REJECT_ALL_BLANK_PROC
  end
end
