# Protected Attributes

[![Build Status](https://api.travis-ci.org/rails/protected_attributes.svg?branch=master)](https://travis-ci.org/rails/protected_attributes)

Protect attributes from mass-assignment in Active Record models.

This plugin adds the class methods `attr_accessible` and `attr_protected` to your models to be able to declare white or black lists of attributes.

Note: This plugin will be officially supported until the release of Rails 5.0.

## Installation

Add this line to your application's `Gemfile`:

    gem 'protected_attributes'

And then execute:

    bundle install

## Usage

Mass assignment security provides an interface for protecting attributes from end-user injection. This plugin provides two class methods in Active Record classes to control access to their attributes. The `attr_protected` method takes a list of attributes that will be ignored in mass-assignment. 

For example:
```ruby
attr_protected :admin
```
`attr_protected` also optionally takes a role option using `:as` which allows you to define multiple mass-assignment groupings. If no role is defined then attributes will be added to the `:default` role.

```ruby
attr_protected :last_login, :as => :admin
```
A much better way, because it follows the whitelist-principle, is the `attr_accessible` method. It is the exact opposite of `attr_protected`, because it takes a list of attributes that will be mass-assigned if present. Any other attributes will be ignored. This way you won’t forget to protect attributes when adding new ones in the course of development. Here is an example:

```ruby
attr_accessible :name
attr_accessible :name, :is_admin, :as => :admin
```

If you want to set a protected attribute, you will to have to assign it individually:

```ruby
params[:user] # => {:name => "owned", :is_admin => true}
@user = User.new(params[:user])
@user.is_admin # => false, not mass-assigned
@user.is_admin = true
@user.is_admin # => true
```

When assigning attributes in Active Record using `attributes=` the `:default` role will be used. To assign attributes using different roles you should use `assign_attributes` which accepts an optional `:as` options parameter. If no `:as` option is provided then the `:default` role will be used. 

You can also bypass mass-assignment security by using the `:without_protection` option. Here is an example:

```ruby
@user = User.new

@user.assign_attributes(:name => 'Josh', :is_admin => true)
@user.name # => Josh
@user.is_admin # => false

@user.assign_attributes({ :name => 'Josh', :is_admin => true }, :as => :admin)
@user.name # => Josh
@user.is_admin # => true

@user.assign_attributes({ :name => 'Josh', :is_admin => true }, :without_protection => true)
@user.name # => Josh
@user.is_admin # => true
```

In a similar way, `new`, `create`, `create!`, `update_attributes` and `update_attributes!` methods all respect mass-assignment security and accept either `:as` or `:without_protection` options. For example:

```ruby
@user = User.new({ :name => 'Sebastian', :is_admin => true }, :as => :admin)
@user.name # => Sebastian
@user.is_admin # => true

@user = User.create({ :name => 'Sebastian', :is_admin => true }, :without_protection => true)
@user.name # => Sebastian
@user.is_admin # => true
```

By default the gem will use the strong parameters protection when assigning attribute, unless your model has `attr_accessible` or `attr_protected` calls.

### Errors

By default, attributes in the params hash which are not allowed to be updated are just ignored. If you prefer an exception to be raised configure:

```ruby
config.active_record.mass_assignment_sanitizer = :strict
```

Any protected attributes violation raises `ActiveModel::MassAssignmentSecurity::Error` then.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
