class CreateAlertCommand < Command
  corresponds_to :create_alert

  def perform
    alert = Alert.create(params)

    if alert.persisted?
      adapters.each { |adapter| adapter.succeeded(alert) }
    else
      adapters.each { |adapter| adapter.failed(alert) }
    end

    alert
  end
end
