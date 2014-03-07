module ActiveRecord
  module MassAssignmentSecurity
    module NestedAttributes
      extend ActiveSupport::Concern

      module ClassMethods

        REJECT_ALL_BLANK_PROC = proc { |attributes| attributes.all? { |key, value| key == '_destroy' || value.blank? } }

        def accepts_nested_attributes_for(*attr_names)
          options = { :allow_destroy => false, :update_only => false }
          options.update(attr_names.extract_options!)
          options.assert_valid_keys(:allow_destroy, :reject_if, :limit, :update_only)
          options[:reject_if] = REJECT_ALL_BLANK_PROC if options[:reject_if] == :all_blank

          attr_names.each do |association_name|
            if reflection = reflect_on_association(association_name)
              reflection.options[:autosave] = true
              add_autosave_association_callbacks(reflection)

              nested_attributes_options = self.nested_attributes_options.dup
              nested_attributes_options[association_name.to_sym] = options
              self.nested_attributes_options = nested_attributes_options

              type = (reflection.collection? ? :collection : :one_to_one)

              generated_methods_module = active_record_40? ? generated_feature_methods : generated_association_methods

              # def pirate_attributes=(attributes)
              #   assign_nested_attributes_for_one_to_one_association(:pirate, attributes, mass_assignment_options)
              # end
              generated_methods_module.module_eval <<-eoruby, __FILE__, __LINE__ + 1
                if method_defined?(:#{association_name}_attributes=)
                  remove_method(:#{association_name}_attributes=)
                end
                def #{association_name}_attributes=(attributes)
                  assign_nested_attributes_for_#{type}_association(:#{association_name}, attributes, mass_assignment_options)
                end
              eoruby
            else
              raise ArgumentError, "No association found for name `#{association_name}'. Has it been defined yet?"
            end
          end
        end
      end

      private

      UNASSIGNABLE_KEYS = %w( id _destroy )

      def assign_nested_attributes_for_one_to_one_association(association_name, attributes, assignment_opts = {})
        options = self.nested_attributes_options[association_name]
        attributes = attributes.with_indifferent_access

        if  (options[:update_only] || !attributes['id'].blank?) && (record = send(association_name)) &&
            (options[:update_only] || record.id.to_s == attributes['id'].to_s)
          assign_to_or_mark_for_destruction(record, attributes, options[:allow_destroy], assignment_opts) unless call_reject_if(association_name, attributes)

        elsif attributes['id'].present? && !assignment_opts[:without_protection]
          raise_nested_attributes_record_not_found!(association_name, attributes['id'])

        elsif !reject_new_record?(association_name, attributes)
          method = "build_#{association_name}"
          if respond_to?(method)
            send(method, attributes.except(*unassignable_keys(assignment_opts)), assignment_opts)
          else
            raise ArgumentError, "Cannot build association `#{association_name}'. Are you trying to build a polymorphic one-to-one association?"
          end
        end
      end

      def assign_nested_attributes_for_collection_association(association_name, attributes_collection, assignment_opts = {})
        options = self.nested_attributes_options[association_name]

        unless attributes_collection.is_a?(Hash) || attributes_collection.is_a?(Array)
          raise ArgumentError, "Hash or Array expected, got #{attributes_collection.class.name} (#{attributes_collection.inspect})"
        end

        if limit = options[:limit]
          limit = case limit
          when Symbol
            send(limit)
          when Proc
            limit.call
          else
            limit
          end

          if limit && attributes_collection.size > limit
            raise TooManyRecords, "Maximum #{limit} records are allowed. Got #{attributes_collection.size} records instead."
          end
        end

        if attributes_collection.is_a? Hash
          keys = attributes_collection.keys
          attributes_collection = if keys.include?('id') || keys.include?(:id)
            [attributes_collection]
          else
            attributes_collection.values
          end
        end

        association = association(association_name)

        existing_records = if association.loaded?
          association.target
        else
          attribute_ids = attributes_collection.map {|a| a['id'] || a[:id] }.compact
          attribute_ids.empty? ? [] : association.scope.where(association.klass.primary_key => attribute_ids)
        end

        attributes_collection.each do |attributes|
          attributes = attributes.with_indifferent_access

          if attributes['id'].blank?
            unless reject_new_record?(association_name, attributes)
              association.build(attributes.except(*unassignable_keys(assignment_opts)), assignment_opts)
            end
          elsif existing_record = existing_records.detect { |record| record.id.to_s == attributes['id'].to_s }
            unless association.loaded? || call_reject_if(association_name, attributes)
              # Make sure we are operating on the actual object which is in the association's
              # proxy_target array (either by finding it, or adding it if not found)
              target_record = association.target.detect { |record| record == existing_record }

              if target_record
                existing_record = target_record
              else
                association.add_to_target(existing_record)
              end
            end

            if !call_reject_if(association_name, attributes)
              assign_to_or_mark_for_destruction(existing_record, attributes, options[:allow_destroy], assignment_opts)
            end
          elsif assignment_opts[:without_protection]
            association.build(attributes.except(*unassignable_keys(assignment_opts)), assignment_opts)
          else
            raise_nested_attributes_record_not_found!(association_name, attributes['id'])
          end
        end
      end

      def assign_to_or_mark_for_destruction(record, attributes, allow_destroy, assignment_opts)
        record.assign_attributes(attributes.except(*unassignable_keys(assignment_opts)), assignment_opts)
        record.mark_for_destruction if has_destroy_flag?(attributes) && allow_destroy
      end

      def unassignable_keys(assignment_opts)
        assignment_opts[:without_protection] ? UNASSIGNABLE_KEYS - %w[id] : UNASSIGNABLE_KEYS
      end
    end
  end
end
