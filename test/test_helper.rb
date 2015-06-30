require 'bundler/setup'
require 'minitest/autorun'
require 'mocha/api'
require 'rails'

ActiveSupport.test_order = :random if ActiveSupport.respond_to?(:test_order)
