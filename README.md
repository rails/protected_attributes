# ProtectedAttributes

Protect attributes from mass-assignment in ActiveRecord models.

This plugin adds `attr_accessible` and `attr_protected` in your models.

## Installation

Add this line to your application's Gemfile:

    gem 'protected_attributes'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install protected_attributes

## Usage

Mass assignment security provides an interface for protecting attributes from end-user assignment. This plugin provides two class methods in your Active Record class to control access to your attributes. The `attr_protected` method takes a list of attributes that will not be accessible for mass-assignment. 

For example:

    attr_protected :admin

`attr_protected` also optionally takes a role option using `:as` which allows you to define multiple mass-assignment groupings. If no role is defined then attributes will be added to the `:default` role.

    attr_protected :last_login, :as => :admin

A much better way, because it follows the whitelist-principle, is the `attr_accessible` method. It is the exact opposite of `attr_protected`, because it takes a list of attributes that will be accessible. All other attributes will be protected. This way you won’t forget to protect attributes when adding new ones in the course of development. Here is an example:

    attr_accessible :name
    attr_accessible :name, :is_admin, :as => :admin

If you want to set a protected attribute, you will to have to assign it individually:

    params[:user] # => {:name => "owned", :is_admin => true}
    @user = User.new(params[:user])
    @user.is_admin # => false, not mass-assigned
    @user.is_admin = true
    @user.is_admin # => true

When assigning attributes in Active Record using `attributes=` the `:default` role will be used. To assign attributes using different roles you should use `assign_attributes` which accepts an optional `:as` options parameter. If no `:as` option is provided then the `:default` role will be used. 
You can also bypass mass-assignment security by using the `:without_protection` option. Here is an example:

    @user = User.new
 
    @user.assign_attributes({ :name => 'Josh', :is_admin => true })
    @user.name # => Josh
    @user.is_admin # => false
 
    @user.assign_attributes({ :name => 'Josh', :is_admin => true }, :as => :admin)
    @user.name # => Josh
    @user.is_admin # => true
 
    @user.assign_attributes({ :name => 'Josh', :is_admin => true }, :without_protection => true)
    @user.name # => Josh
    @user.is_admin # => true

In a similar way, `new`, `create`, `create!`, `update_attributes` and `update_attributes!` methods all respect mass-assignment security and accept either `:as` or `:without_protection` options. For example:

    @user = User.new({ :name => 'Sebastian', :is_admin => true }, :as => :admin)
    @user.name # => Sebastian
    @user.is_admin # => true
 
    @user = User.create({ :name => 'Sebastian', :is_admin => true }, :without_protection => true)
    @user.name # => Sebastian
    @user.is_admin # => true

A more paranoid technique to protect your whole project would be to enforce that all models define their accessible attributes. 
This can be easily achieved with a very simple application config option of:

    config.active_record.whitelist_attributes = true

This will create an empty whitelist of attributes available for mass-assignment for all models in your app. 
As such, your models will need to explicitly whitelist or blacklist accessible parameters by using an `attr_accessible` or `attr_protected` declaration. This technique is best applied at the start of a new project. However, for an existing project with a thorough set of functional tests, it should be straightforward and relatively quick to use this application config option; run your tests, and expose each attribute (via `attr_accessible` or `attr_protected`), as dictated by your failing test.

For more complex permissions, mass-assignment security may be handled outside the model by extending a non-ActiveRecord class, such as a controller, with this behavior.

For example, a logged-in user may need to assign additional attributes depending on their role:

    class AccountsController < ApplicationController
      include ActiveModel::MassAssignmentSecurity

      attr_accessible :first_name, :last_name
      attr_accessible :first_name, :last_name, :plan_id, :as => :admin

      def update
        ...
        @account.update_attributes(account_params)
        ...
      end

      protected

      def account_params
        role = admin ? :admin : :default
        sanitize_for_mass_assignment(params[:account], role)
      end
    end

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
