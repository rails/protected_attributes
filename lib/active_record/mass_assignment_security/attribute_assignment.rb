require 'active_model/mass_assignment_security'
require 'active_record'

module ActiveRecord
  module MassAssignmentSecurity
    module AttributeAssignment
      extend ActiveSupport::Concern
      include ActiveModel::MassAssignmentSecurity

      module ClassMethods
        private

        # The primary key and inheritance column can never be set by mass-assignment for security reasons.
        def attributes_protected_by_default
          default = [ primary_key, inheritance_column ]
          default << 'id' unless primary_key.eql? 'id'
          default
        end
      end

      # Allows you to set all the attributes for a particular mass-assignment
      # security role by passing in a hash of attributes with keys matching
      # the attribute names (which again matches the column names) and the role
      # name using the :as option.
      #
      # To bypass mass-assignment security you can use the :without_protection => true
      # option.
      #
      #   class User < ActiveRecord::Base
      #     attr_accessible :name
      #     attr_accessible :name, :is_admin, :as => :admin
      #   end
      #
      #   user = User.new
      #   user.assign_attributes({ :name => 'Josh', :is_admin => true })
      #   user.name       # => "Josh"
      #   user.is_admin?  # => false
      #
      #   user = User.new
      #   user.assign_attributes({ :name => 'Josh', :is_admin => true }, :as => :admin)
      #   user.name       # => "Josh"
      #   user.is_admin?  # => true
      #
      #   user = User.new
      #   user.assign_attributes({ :name => 'Josh', :is_admin => true }, :without_protection => true)
      #   user.name       # => "Josh"
      #   user.is_admin?  # => true
      def assign_attributes(new_attributes, options = {})
        return if new_attributes.blank?

        attributes                  = new_attributes.stringify_keys
        multi_parameter_attributes  = []
        nested_parameter_attributes = []
        previous_options            = @mass_assignment_options
        @mass_assignment_options    = options

        unless options[:without_protection]
          attributes = sanitize_for_mass_assignment(attributes, mass_assignment_role)
        end

        attributes.each do |k, v|
          if k.include?("(")
            multi_parameter_attributes << [ k, v ]
          elsif v.is_a?(Hash)
            nested_parameter_attributes << [ k, v ]
          else
            _assign_attribute(k, v)
          end
        end

        assign_nested_parameter_attributes(nested_parameter_attributes) unless nested_parameter_attributes.empty?
        assign_multiparameter_attributes(multi_parameter_attributes) unless multi_parameter_attributes.empty?
      ensure
        @mass_assignment_options = previous_options
      end

      protected

      def mass_assignment_options
        @mass_assignment_options ||= {}
      end

      def mass_assignment_role
        mass_assignment_options[:as] || :default
      end
    end
  end
end
