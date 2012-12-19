require 'rails/railtie'

module ProtectedAttributes
  class Railtie < ::Rails::Railtie
    config.before_configuration do |app|
      config.action_controller.permit_all_parameters = true
      config.active_record.whitelist_attributes = true if config.respond_to?(:active_record)
    end

    initializer "protected_attributes.active_record", :before => "active_record.set_configs" do |app|
      ActiveSupport.on_load :active_record do
        if app.config.respond_to?(:active_record) && app.config.active_record.delete(:whitelist_attributes)
          attr_accessible(nil)
        end
      end
    end
  end
end
