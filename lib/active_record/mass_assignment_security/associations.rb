module ActiveRecord
  module Associations
    class Association
      def build_record(attributes, options)
        reflection.build_association(attributes, options) do |record|
          attributes = create_scope.except(*(record.changed - [reflection.foreign_key]))
          record.assign_attributes(attributes, without_protection: true)
        end
      end

      private :build_record
    end

    class CollectionAssociation
      def build(attributes = {}, options = {}, &block)
        if attributes.is_a?(Array)
          attributes.collect { |attr| build(attr, options, &block) }
        else
          add_to_target(build_record(attributes, options)) do |record|
            yield(record) if block_given?
          end
        end
      end

      def create(attributes = {}, options = {}, &block)
        create_record(attributes, options, &block)
      end

      def create!(attributes = {}, options = {}, &block)
        create_record(attributes, options, true, &block)
      end

      def create_record(attributes, options, raise = false, &block)
        unless owner.persisted?
          raise ActiveRecord::RecordNotSaved, "You cannot call create unless the parent is saved"
        end

        if attributes.is_a?(Array)
          attributes.collect { |attr| create_record(attr, options, raise, &block) }
        else
          transaction do
            add_to_target(build_record(attributes, options)) do |record|
              yield(record) if block_given?
              insert_record(record, true, raise)
            end
          end
        end
      end

      private :create_record
    end

    class CollectionProxy
      def build(attributes = {}, options = {}, &block)
        @association.build(attributes, options, &block)
      end

      def create(attributes = {}, options = {}, &block)
        @association.create(attributes, options, &block)
      end

      def create!(attributes = {}, options = {}, &block)
        @association.create!(attributes, options, &block)
      end
    end

    class HasManyThroughAssociation
      def build_record(attributes, options = {})
        ensure_not_nested

        record = super(attributes, options)

        inverse = source_reflection.inverse_of
        if inverse
          if inverse.macro == :has_many
            record.send(inverse.name) << build_through_record(record)
          elsif inverse.macro == :has_one
            record.send("#{inverse.name}=", build_through_record(record))
          end
        end

        record
      end

      private :build_record
    end

    class SingularAssociation
      def create(attributes = {}, options = {}, &block)
        create_record(attributes, options, &block)
      end

      def create!(attributes = {}, options = {}, &block)
        create_record(attributes, options, true, &block)
      end

      def build(attributes = {}, options = {})
        record = build_record(attributes, options)
        yield(record) if block_given?
        set_new_record(record)
        record
      end

      def create_record(attributes, options = {}, raise_error = false)
        record = build_record(attributes, options)
        yield(record) if block_given?
        saved = record.save
        set_new_record(record)
        raise RecordInvalid.new(record) if !saved && raise_error
        record
      end

      private :create_record
    end
  end
end
