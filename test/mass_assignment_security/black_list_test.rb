require 'test_helper'
require 'active_model/mass_assignment_security'

class BlackListTest < ActiveModel::TestCase

  def setup
    @black_list   = ActiveModel::MassAssignmentSecurity::BlackList.new
    @included_key = 'admin'
    @black_list  += [ @included_key ]
  end

  test "deny? is true for included items" do
    assert_equal true, @black_list.deny?(@included_key)
  end

  test "deny? is false for non-included items" do
    assert_equal false, @black_list.deny?('first_name')
  end


end
