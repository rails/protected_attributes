# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'protected_attributes/version'

Gem::Specification.new do |gem|
  gem.name          = "protected_attributes"
  gem.version       = ProtectedAttributes::VERSION
  gem.authors       = ["David Heinemeier Hansson"]
  gem.email         = ["david@loudthinking.com"]
  gem.description   = %q{Protect attributes from mass assignment}
  gem.summary       = %q{Protect attributes from mass assignment in Active Record models}
  gem.homepage      = "https://github.com/rails/protected_attributes"
  gem.license       = "MIT"

  gem.files         = Dir["LICENSE.txt", "README.md", "lib/**/*"]
  gem.require_paths = ["lib"]

  gem.add_dependency "activemodel",  ">= 4.0.1", "<6.0"

  gem.add_development_dependency "activerecord", ">= 4.0.1", "<6.0"
  gem.add_development_dependency "actionpack",   ">= 4.0.1", "<6.0"
  gem.add_development_dependency "railties",   ">= 4.0.1", "<6.0"
  gem.add_development_dependency "sqlite3"
  gem.add_development_dependency "mocha"
end
