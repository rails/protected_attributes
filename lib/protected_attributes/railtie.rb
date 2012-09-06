module ProtectedAttributes
  class Railtie < ::Rails::Railtie
    config.before_configuration do
      config.action_controller.permit_all_parameters = true
      config.active_record.whitelist_attributes = true
    end
  end
end
