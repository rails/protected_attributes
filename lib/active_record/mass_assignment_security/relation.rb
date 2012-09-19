module ActiveRecord
  module MassAssignmentSecurity
    module Relation
      # Tries to load the first record; if it fails, then <tt>create</tt> is called with the same arguments as this method.
      #
      # Expects arguments in the same format as +Base.create+.
      #
      # ==== Examples
      #   # Find the first user named Penélope or create a new one.
      #   User.where(:first_name => 'Penélope').first_or_create
      #   # => <User id: 1, first_name: 'Penélope', last_name: nil>
      #
      #   # Find the first user named Penélope or create a new one.
      #   # We already have one so the existing record will be returned.
      #   User.where(:first_name => 'Penélope').first_or_create
      #   # => <User id: 1, first_name: 'Penélope', last_name: nil>
      #
      #   # Find the first user named Scarlett or create a new one with a particular last name.
      #   User.where(:first_name => 'Scarlett').first_or_create(:last_name => 'Johansson')
      #   # => <User id: 2, first_name: 'Scarlett', last_name: 'Johansson'>
      #
      #   # Find the first user named Scarlett or create a new one with a different last name.
      #   # We already have one so the existing record will be returned.
      #   User.where(:first_name => 'Scarlett').first_or_create do |user|
      #     user.last_name = "O'Hara"
      #   end
      #   # => <User id: 2, first_name: 'Scarlett', last_name: 'Johansson'>
      def first_or_create(attributes = nil, options = {}, &block)
        first || create(attributes, options, &block)
      end

      # Like <tt>first_or_create</tt> but calls <tt>create!</tt> so an exception is raised if the created record is invalid.
      #
      # Expects arguments in the same format as <tt>Base.create!</tt>.
      def first_or_create!(attributes = nil, options = {}, &block)
        first || create!(attributes, options, &block)
      end

      # Like <tt>first_or_create</tt> but calls <tt>new</tt> instead of <tt>create</tt>.
      #
      # Expects arguments in the same format as <tt>Base.new</tt>.
      def first_or_initialize(attributes = nil, &block)
        first || new(attributes, options, &block)
      end
    end
  end
end
