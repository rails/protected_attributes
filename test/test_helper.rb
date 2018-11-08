require 'bundler/setup'
require 'minitest/autorun'
require 'mocha/minitest'
require 'rails'

ActiveSupport.test_order = :random if ActiveSupport.respond_to?(:test_order)
