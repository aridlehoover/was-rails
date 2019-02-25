class CreateAlertOperation
  attr_reader :params, :adapter

  def initialize(params, adapter)
    @params = params
    @adapter = adapter
  end

  def perform
    alert = Alert.create(params)

    if alert.persisted?
      adapter.operation_succeeded
    else
      adapter.operation_failed(alert)
    end

    alert
  end
end
