require 'active_support/concern'
require 'action_controller'
require 'action_controller/metal/params_wrapper'

module ActionController
  module ParamsWrapper
    class Options # :nodoc:
      def include
        return super if @include_set

        m = model
        synchronize do
          return super if @include_set

          @include_set = true

          unless super || exclude

            if m.respond_to?(:accessible_attributes) && m.accessible_attributes(:default).present?
              self.include = m.accessible_attributes(:default).to_a
            elsif m.respond_to?(:attribute_names) && m.attribute_names.any?
              self.include = m.attribute_names
            end
          end
        end
      end
    end
  end
end
