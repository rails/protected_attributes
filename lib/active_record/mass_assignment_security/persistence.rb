require 'active_support/concern'

module ActiveRecord
  module MassAssignmentSecurity
    # = Active Record Persistence
    module Persistence
      extend ActiveSupport::Concern

      module ClassMethods
        # Creates an object (or multiple objects) and saves it to the database, if validations pass.
        # The resulting object is returned whether the object was saved successfully to the database or not.
        #
        # The +attributes+ parameter can be either a Hash or an Array of Hashes. These Hashes describe the
        # attributes on the objects that are to be created.
        #
        # +create+ respects mass-assignment security and accepts either +:as+ or +:without_protection+ options
        # in the +options+ parameter.
        #
        # ==== Examples
        #   # Create a single new object
        #   User.create(:first_name => 'Jamie')
        #
        #   # Create a single new object using the :admin mass-assignment security role
        #   User.create({ :first_name => 'Jamie', :is_admin => true }, :as => :admin)
        #
        #   # Create a single new object bypassing mass-assignment security
        #   User.create({ :first_name => 'Jamie', :is_admin => true }, :without_protection => true)
        #
        #   # Create an Array of new objects
        #   User.create([{ :first_name => 'Jamie' }, { :first_name => 'Jeremy' }])
        #
        #   # Create a single object and pass it into a block to set other attributes.
        #   User.create(:first_name => 'Jamie') do |u|
        #     u.is_admin = false
        #   end
        #
        #   # Creating an Array of new objects using a block, where the block is executed for each object:
        #   User.create([{ :first_name => 'Jamie' }, { :first_name => 'Jeremy' }]) do |u|
        #     u.is_admin = false
        #   end
        def create(attributes = nil, options = {}, &block)
          if attributes.is_a?(Array)
            attributes.collect { |attr| create(attr, options, &block) }
          else
            object = new(attributes, options, &block)
            object.save
            object
          end
        end
      end

      # Updates the attributes of the model from the passed-in hash and saves the
      # record, all wrapped in a transaction. If the object is invalid, the saving
      # will fail and false will be returned.
      #
      # When updating model attributes, mass-assignment security protection is respected.
      # If no +:as+ option is supplied then the +:default+ role will be used.
      # If you want to bypass the forbidden attributes protection then you can do so using
      # the +:without_protection+ option.
      def update_attributes(attributes, options = {})
        # The following transaction covers any possible database side-effects of the
        # attributes assignment. For example, setting the IDs of a child collection.
        with_transaction_returning_status do
          assign_attributes(attributes, options)
          save
        end
      end

      # Updates its receiver just like +update_attributes+ but calls <tt>save!</tt> instead
      # of +save+, so an exception is raised if the record is invalid.
      def update_attributes!(attributes, options = {})
        # The following transaction covers any possible database side-effects of the
        # attributes assignment. For example, setting the IDs of a child collection.
        with_transaction_returning_status do
          assign_attributes(attributes, options)
          save!
        end
      end
    end
  end
end
