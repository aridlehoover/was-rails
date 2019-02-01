class CreateAlertJob < ApplicationJob
  ALLOWED_ATTRIBUTES = ['uuid', 'title', 'location', 'message', 'publish_at', 'effective_at', 'expires_at'].freeze

  def perform(alert_attributes)
    allowed_alert_params = alert_attributes.slice(*ALLOWED_ATTRIBUTES)
    alert = Alert.create(allowed_alert_params)

    if alert.persisted?
      WASLogger.json(action: :create_alert, status: :succeeded, params: allowed_alert_params)
    else
      WASLogger.json(action: :create_alert, status: :failed, params: allowed_alert_params)
    end
  end
end
