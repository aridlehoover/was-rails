class CreateAlertCommand
  attr_reader :params, :adapters

  def initialize(params, adapters)
    @params = params
    @adapters = Array.wrap(adapters).compact
  end

  def perform
    alert = Alert.create(params)

    if alert.persisted?
      adapters.each { |adapter| adapter.operation_succeeded(alert) }
    else
      adapters.each { |adapter| adapter.operation_failed(alert) }
    end

    alert
  end
end
