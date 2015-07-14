module ProtectedAttributes
  class Railtie < ::Rails::Railtie
    initializer "protected_attributes.active_record", :before => "active_record.set_configs" do |app|
      if app.config.respond_to?(:active_record) && app.config.active_record.delete(:whitelist_attributes)
        ActiveSupport::Deprecation.warn "config.active_record.whitelist_attributes is deprecated and have no effect. Remove its call from the configuration."
      end
    end
  end
end
