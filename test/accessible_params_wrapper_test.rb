require 'test_helper'
require 'abstract_unit'
require 'action_controller/accessible_params_wrapper'

module ParamsWrapperTestHelp
  def with_default_wrapper_options(&block)
    @controller.class._set_wrapper_options({:format => [:json]})
    @controller.class.inherited(@controller.class)
    yield
  end

  def assert_parameters(expected)
    assert_equal expected, self.class.controller_class.last_parameters
  end
end

class AccessibleParamsWrapperTest < ActionController::TestCase
  include ParamsWrapperTestHelp

  class UsersController < ActionController::Base
    class << self
      attr_accessor :last_parameters
    end

    def parse
      self.class.last_parameters = request.params.except(:controller, :action)
      head :ok
    end
  end

  class User; end
  class Person; end

  tests UsersController

  def teardown
    UsersController.last_parameters = nil
  end

  def test_derived_wrapped_keys_from_matching_model
    User.expects(:respond_to?).with(:accessible_attributes).returns(false)
    User.expects(:respond_to?).with(:attribute_names).returns(true)
    User.expects(:attribute_names).twice.returns(["username"])

    with_default_wrapper_options do
      @request.env['CONTENT_TYPE'] = 'application/json'
      post :parse, { 'username' => 'sikachu', 'title' => 'Developer' }
      assert_parameters({ 'username' => 'sikachu', 'title' => 'Developer', 'user' => { 'username' => 'sikachu' }})
    end
  end

  def test_derived_wrapped_keys_from_specified_model
    with_default_wrapper_options do
      Person.expects(:respond_to?).with(:accessible_attributes).returns(false)
      Person.expects(:respond_to?).with(:attribute_names).returns(true)
      Person.expects(:attribute_names).twice.returns(["username"])

      UsersController.wrap_parameters Person

      @request.env['CONTENT_TYPE'] = 'application/json'
      post :parse, { 'username' => 'sikachu', 'title' => 'Developer' }
      assert_parameters({ 'username' => 'sikachu', 'title' => 'Developer', 'person' => { 'username' => 'sikachu' }})
    end
  end

  def test_accessible_wrapped_keys_from_matching_model
    User.expects(:respond_to?).with(:accessible_attributes).returns(true)
    User.expects(:accessible_attributes).with(:default).twice.returns(["username"])

    with_default_wrapper_options do
      @request.env['CONTENT_TYPE'] = 'application/json'
      post :parse, { 'username' => 'sikachu', 'title' => 'Developer' }
      assert_parameters({ 'username' => 'sikachu', 'title' => 'Developer', 'user' => { 'username' => 'sikachu' }})
    end
  end
end
