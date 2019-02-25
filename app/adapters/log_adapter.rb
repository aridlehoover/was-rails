class LogAdapter
  attr_reader :params, :options

  def initialize(params, options = {})
    @params = params
    @options = options
  end

  def operation_succeeded
    ExternalLogger.log_and_increment(
      {
        action: :create_alert,
        actor: :administrator,
        status: :succeeded,
        params: params
      }.merge(options)
    )
  end

  def operation_failed(alert)
    ExternalLogger.log_and_increment(
      {
        action: :create_alert,
        actor: :administrator,
        status: :failed,
        params: params,
        errors: alert.errors.messages
      }.merge(options)
    )
  end
end
