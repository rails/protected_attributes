module ProtectedAttributes
  class Railtie < ::Rails::Railtie
    config.before_configuration do |app|
      config.action_controller.permit_all_parameters = true
      config.active_record.whitelist_attributes = true

      ActiveSupport.on_load(:active_record) do
        if app.config.active_record.delete(:whitelist_attributes)
          attr_accessible(nil)
        end
      end
    end
  end
end
