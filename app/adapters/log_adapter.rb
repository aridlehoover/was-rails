class LogAdapter
  attr_reader :params

  def initialize(params)
    @params = params
  end

  def operation_succeeded
    ExternalLogger.log_and_increment(
      action: :create_alert,
      actor: :administrator,
      status: :succeeded,
      params: params
    )
  end

  def operation_failed(alert)
    ExternalLogger.log_and_increment(
      action: :create_alert,
      actor: :administrator,
      status: :failed,
      params: params,
      errors: alert.errors.messages
    )
  end
end
