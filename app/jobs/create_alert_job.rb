class CreateAlertJob < ApplicationJob
  ALLOWED_ATTRIBUTES = ['uuid', 'title', 'location', 'message', 'publish_at', 'effective_at', 'expires_at'].freeze

  def perform(alert_attributes)
    Alert.create(alert_attributes.slice(*ALLOWED_ATTRIBUTES))
  end
end
