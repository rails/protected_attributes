require 'active_support/concern'
require 'action_controller'

module ActionController
  module AccessibleParamsWrapper
    extend ActiveSupport::Concern

    module ClassMethods
      protected

      def _set_wrapper_defaults(options, model=nil)
        options = options.dup

        unless options[:include] || options[:exclude]
          model ||= _default_wrap_model
          role = options.fetch(:as, :default)
          if model.respond_to?(:accessible_attributes) && model.accessible_attributes(role).present?
            options[:include] = model.accessible_attributes(role).to_a
          elsif model.respond_to?(:attribute_names) && model.attribute_names.present?
            options[:include] = model.attribute_names
          end
        end

        unless options[:name] || self.anonymous?
          model ||= _default_wrap_model
          options[:name] = model ? model.to_s.demodulize.underscore :
            controller_name.singularize
        end

        options[:include] = Array(options[:include]).collect(&:to_s) if options[:include]
        options[:exclude] = Array(options[:exclude]).collect(&:to_s) if options[:exclude]
        options[:format]  = Array(options[:format])

        self._wrapper_options = options
      end
    end
  end
end

ActionController::Base.send :include, ActionController::AccessibleParamsWrapper
